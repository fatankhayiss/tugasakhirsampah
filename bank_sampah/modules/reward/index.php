<?php
// modules/reward/index.php
// Admin Reward Redemption Dashboard (Action-Based Processing)
check_user_level(['admin']);

// Handle quick actions submitted via POST
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action_type'])) {
    $action_type = $_POST['action_type'];
    $redemption_id = isset($_POST['redemption_id']) ? (int)$_POST['redemption_id'] : 0;
    $admin_id = (int)$_SESSION['user_id'];
    
    if ($redemption_id > 0) {
        $stmt_g = mysqli_prepare($koneksi, "SELECT * FROM reward_redemptions WHERE id = ? LIMIT 1");
        mysqli_stmt_bind_param($stmt_g, "i", $redemption_id);
        mysqli_stmt_execute($stmt_g);
        $row_q = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_g));
        mysqli_stmt_close($stmt_g);
        
        if ($row_q) {
            $old_status = $row_q['status'];
            $trx_code = $row_q['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row_q['created_at'])), $row_q['id']);
            $uid = (int)$row_q['user_id'];
            $pts = (int)$row_q['redeem_point'];
            
            // COMPLETE ACTION
            if ($action_type === 'complete' && ($old_status === 'processing' || $old_status === 'pending')) {
                $transfer_proof_path = null;
                if (isset($_FILES['transfer_proof']) && $_FILES['transfer_proof']['error'] === UPLOAD_ERR_OK) {
                    $upload_dir = __DIR__ . '/../../uploads/transfer_proof/';
                    if (!is_dir($upload_dir)) mkdir($upload_dir, 0777, true);
                    $ext = pathinfo($_FILES['transfer_proof']['name'], PATHINFO_EXTENSION);
                    $filename = 'proof_' . $trx_code . '_' . time() . '.' . $ext;
                    if (move_uploaded_file($_FILES['transfer_proof']['tmp_name'], $upload_dir . $filename)) {
                        $transfer_proof_path = 'uploads/transfer_proof/' . $filename;
                    }
                }
                
                if (!$transfer_proof_path) {
                    echo "<script>alert('Bukti transfer wajib diunggah!'); window.history.back();</script>";
                    exit;
                }

                mysqli_begin_transaction($koneksi);
                try {
                    if ($old_status !== 'completed' && $old_status !== 'rejected') {
                        mysqli_query($koneksi, "UPDATE pengguna SET reserved_saldo = GREATEST(0, COALESCE(reserved_saldo, 0) - $pts) WHERE id_pengguna = $uid");
                    }
                    
                    $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'completed', completed_at = NOW(), admin_id = ?, transfer_proof = ? WHERE id = ?");
                    mysqli_stmt_bind_param($stmt, "isi", $admin_id, $transfer_proof_path, $redemption_id);
                    mysqli_stmt_execute($stmt);
                    mysqli_stmt_close($stmt);
                    
                    mysqli_query($koneksi, "INSERT INTO redemption_audit_logs (redemption_id, transaction_code, action, old_status, new_status, admin_id, reason, created_at) VALUES ($redemption_id, '$trx_code', 'COMPLETE', '$old_status', 'completed', $admin_id, 'Penukaran diselesaikan langsung dari index dengan bukti transfer', NOW())");
                    mysqli_query($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES ($uid, 'Tukar Poin Berhasil', 'Penukaran poin Anda telah selesai diproses. Silakan cek riwayat transaksi Anda. Kode: $trx_code', 'success')");
                    
                    mysqli_commit($koneksi);
                    echo "<script>window.location.href='index.php?page=reward/index&tab=completed';</script>";
                    exit;
                } catch (Exception $e) {
                    mysqli_rollback($koneksi);
                }
            }
            
            // REJECT ACTION
            if ($action_type === 'reject') {
                $note = trim($_POST['reject_reason'] ?? '');
                if (empty($note)) {
                    echo "<script>alert('Alasan penolakan wajib diisi!'); window.history.back();</script>";
                    exit;
                }
                mysqli_begin_transaction($koneksi);
                try {
                    if ($old_status !== 'rejected' && $old_status !== 'completed') {
                        mysqli_query($koneksi, "UPDATE pengguna SET saldo = saldo + $pts, reserved_saldo = GREATEST(0, COALESCE(reserved_saldo, 0) - $pts) WHERE id_pengguna = $uid");
                    }
                    
                    $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'rejected', admin_note = ?, rejection_reason = ?, completed_at = NOW(), admin_id = ? WHERE id = ?");
                    mysqli_stmt_bind_param($stmt, "ssii", $note, $note, $admin_id, $redemption_id);
                    mysqli_stmt_execute($stmt);
                    mysqli_stmt_close($stmt);
                    
                    $safe_note = mysqli_real_escape_string($koneksi, $note);
                    mysqli_query($koneksi, "INSERT INTO redemption_audit_logs (redemption_id, transaction_code, action, old_status, new_status, admin_id, reason, created_at) VALUES ($redemption_id, '$trx_code', 'REJECT', '$old_status', 'rejected', $admin_id, '$safe_note', NOW())");
                    mysqli_query($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES ($uid, 'Tukar Poin Ditolak', 'Pengajuan penukaran poin ditolak. Alasan: $safe_note. Kode: $trx_code', 'warning')");
                    
                    mysqli_commit($koneksi);
                    echo "<script>window.location.href='index.php?page=reward/index&tab=rejected';</script>";
                    exit;
                } catch (Exception $e) {
                    mysqli_rollback($koneksi);
                }
            }
        }
    }
}


$tab = isset($_GET['tab']) ? $_GET['tab'] : 'pending';
$status_filter = 'pending';
if ($tab === 'processing') $status_filter = 'processing';
elseif ($tab === 'completed') $status_filter = 'completed';
elseif ($tab === 'rejected') $status_filter = 'rejected';
elseif ($tab === 'all') $status_filter = '';

$search = trim($_GET['search'] ?? '');
$from_date = trim($_GET['from_date'] ?? '');
$to_date = trim($_GET['to_date'] ?? '');
$sort = trim($_GET['sort'] ?? 'terbaru');

$sql = "SELECT r.*, u.nama_lengkap as nama_warga, u.no_telepon as telp_warga 
        FROM reward_redemptions r 
        JOIN pengguna u ON r.user_id = u.id_pengguna WHERE 1=1 ";
if ($status_filter) {
    $sql .= "AND r.status = '" . mysqli_real_escape_string($koneksi, $status_filter) . "' ";
}
if (!empty($search)) {
    $s_esc = mysqli_real_escape_string($koneksi, $search);
    $sql .= "AND (r.transaction_code LIKE '%$s_esc%' OR u.nama_lengkap LIKE '%$s_esc%' OR r.provider LIKE '%$s_esc%' OR r.account_number LIKE '%$s_esc%' OR r.account_name LIKE '%$s_esc%' OR r.account_holder_name LIKE '%$s_esc%') ";
}
if (!empty($from_date)) {
    $f_esc = mysqli_real_escape_string($koneksi, $from_date);
    $sql .= "AND DATE(r.created_at) >= '$f_esc' ";
}
if (!empty($to_date)) {
    $t_esc = mysqli_real_escape_string($koneksi, $to_date);
    $sql .= "AND DATE(r.created_at) <= '$t_esc' ";
}

if ($sort === 'terlama') {
    $sql .= "ORDER BY r.created_at ASC";
} elseif ($sort === 'poin_desc') {
    $sql .= "ORDER BY r.redeem_point DESC, r.created_at DESC";
} elseif ($sort === 'poin_asc') {
    $sql .= "ORDER BY r.redeem_point ASC, r.created_at DESC";
} elseif ($sort === 'nominal_desc') {
    $sql .= "ORDER BY r.estimated_amount DESC, r.created_at DESC";
} elseif ($sort === 'nominal_asc') {
    $sql .= "ORDER BY r.estimated_amount ASC, r.created_at DESC";
} else {
    $sql .= "ORDER BY r.created_at DESC";
}

$result = mysqli_query($koneksi, $sql);
?>

<div class="space-y-6">
    <!-- Header Page -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">Manajemen Tukar Poin (Redemption)</h1>
            <p class="text-sm text-gray-500 mt-1">Alur pemrosesan berbasis action. Admin tidak mengubah status secara manual demi konsistensi data & audit trail.</p>
        </div>
        <div class="flex items-center space-x-3">
            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-800">
                <i class="fas fa-shield-alt mr-1.5"></i> Action-Based Protected
            </span>
        </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="border-b border-gray-200">
        <nav class="-mb-px flex space-x-8 overflow-x-auto">
            <a href="index.php?page=reward/index&tab=processing&search=<?php echo urlencode($search); ?>&from_date=<?php echo urlencode($from_date); ?>&to_date=<?php echo urlencode($to_date); ?>&sort=<?php echo urlencode($sort); ?>" 
               class="pb-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap <?php echo ($tab=='processing') ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'; ?>">
                <i class="fas fa-spinner fa-spin mr-2"></i> Diproses
            </a>
            <a href="index.php?page=reward/index&tab=completed&search=<?php echo urlencode($search); ?>&from_date=<?php echo urlencode($from_date); ?>&to_date=<?php echo urlencode($to_date); ?>&sort=<?php echo urlencode($sort); ?>" 
               class="pb-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap <?php echo ($tab=='completed') ? 'border-emerald-500 text-emerald-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'; ?>">
                <i class="fas fa-check-circle mr-2"></i> Selesai
            </a>
            <a href="index.php?page=reward/index&tab=rejected&search=<?php echo urlencode($search); ?>&from_date=<?php echo urlencode($from_date); ?>&to_date=<?php echo urlencode($to_date); ?>&sort=<?php echo urlencode($sort); ?>" 
               class="pb-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap <?php echo ($tab=='rejected') ? 'border-red-500 text-red-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'; ?>">
                <i class="fas fa-times-circle mr-2"></i> Ditolak
            </a>
            <a href="index.php?page=reward/index&tab=all&search=<?php echo urlencode($search); ?>&from_date=<?php echo urlencode($from_date); ?>&to_date=<?php echo urlencode($to_date); ?>&sort=<?php echo urlencode($sort); ?>" 
               class="pb-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap <?php echo ($tab=='all') ? 'border-purple-500 text-purple-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'; ?>">
                <i class="fas fa-list mr-2"></i> Semua Riwayat
            </a>
        </nav>
    </div>

    <!-- Filter & Search Bar -->
    <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
        <form method="GET" action="index.php" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
            <input type="hidden" name="page" value="reward/index">
            <input type="hidden" name="tab" value="<?php echo htmlspecialchars($tab); ?>">
            
            <div class="md:col-span-4">
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1"><i class="fas fa-search mr-1"></i> Search</label>
                <input type="text" name="search" value="<?php echo htmlspecialchars($search); ?>" placeholder="Cari kode transaksi, nama warga, provider/rekening..." class="w-full px-3.5 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500">
            </div>
            
            <div class="md:col-span-3">
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1"><i class="fas fa-calendar-alt mr-1"></i> Date Filter (Dari - Sampai)</label>
                <div class="flex items-center space-x-2">
                    <input type="date" name="from_date" value="<?php echo htmlspecialchars($from_date); ?>" class="w-full px-2.5 py-2 rounded-xl border border-gray-200 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
                    <span class="text-gray-400">-</span>
                    <input type="date" name="to_date" value="<?php echo htmlspecialchars($to_date); ?>" class="w-full px-2.5 py-2 rounded-xl border border-gray-200 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500">
                </div>
            </div>
            
            <div class="md:col-span-3">
                <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1"><i class="fas fa-sort mr-1"></i> Sorting</label>
                <select name="sort" class="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 bg-white">
                    <option value="terbaru" <?php echo ($sort === 'terbaru') ? 'selected' : ''; ?>>Terbaru (Submission Date DESC)</option>
                    <option value="terlama" <?php echo ($sort === 'terlama') ? 'selected' : ''; ?>>Terlama (Submission Date ASC)</option>
                    <option value="poin_desc" <?php echo ($sort === 'poin_desc') ? 'selected' : ''; ?>>Poin Terbanyak</option>
                    <option value="poin_asc" <?php echo ($sort === 'poin_asc') ? 'selected' : ''; ?>>Poin Terkecil</option>
                    <option value="nominal_desc" <?php echo ($sort === 'nominal_desc') ? 'selected' : ''; ?>>Estimated Amount Tertinggi</option>
                    <option value="nominal_asc" <?php echo ($sort === 'nominal_asc') ? 'selected' : ''; ?>>Estimated Amount Terendah</option>
                </select>
            </div>
            
            <div class="md:col-span-2 flex items-center space-x-2">
                <button type="submit" class="w-full px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-semibold rounded-xl transition duration-150 flex items-center justify-center">
                    <i class="fas fa-filter mr-1.5"></i> Filter
                </button>
                <?php if (!empty($search) || !empty($from_date) || !empty($to_date) || $sort !== 'terbaru'): ?>
                <a href="index.php?page=reward/index&tab=<?php echo htmlspecialchars($tab); ?>" class="px-3 py-2 bg-gray-100 hover:bg-gray-200 text-gray-600 text-sm font-semibold rounded-xl transition duration-150" title="Reset Filter">
                    <i class="fas fa-sync-alt"></i>
                </a>
                <?php endif; ?>
            </div>
        </form>
    </div>

    <!-- Table Content -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-gray-50 border-b border-gray-100 text-gray-600 text-xs uppercase font-semibold tracking-wider">
                        <th class="py-4 px-5">Transaction Code</th>
                        <th class="py-4 px-5">Citizen Name</th>
                        <th class="py-4 px-5">Destination</th>
                        <th class="py-4 px-5">Provider & Account</th>
                        <th class="py-4 px-5 text-right">Redeemed Points</th>
                        <th class="py-4 px-5 text-right">Estimated Amount</th>
                        <th class="py-4 px-5">Submission Date</th>
                        <th class="py-4 px-5">Current Status</th>
                        <th class="py-4 px-5 text-right">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 text-sm text-gray-700">
                    <?php if ($result && mysqli_num_rows($result) > 0): ?>
                        <?php while ($row = mysqli_fetch_assoc($result)): 
                            $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);
                            $acc_holder = $row['account_holder_name'] ?: $row['account_name'];
                        ?>
                        <tr class="hover:bg-gray-50/80 transition duration-150">
                            <td class="py-4 px-5 font-mono">
                                <a href="index.php?page=reward/detail&id=<?php echo $row['id']; ?>" class="font-bold text-emerald-600 hover:underline">
                                    <?php echo htmlspecialchars($trx_code); ?>
                                </a>
                            </td>
                            <td class="py-4 px-5">
                                <div class="font-semibold text-gray-800"><?php echo htmlspecialchars($row['nama_warga']); ?></div>
                                <div class="text-xs text-gray-500">ID: #<?php echo $row['user_id']; ?> · <?php echo htmlspecialchars($row['telp_warga']); ?></div>
                            </td>
                            <td class="py-4 px-5">
                                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-700 uppercase">
                                    <?php echo htmlspecialchars($row['destination_type']); ?>
                                </span>
                            </td>
                            <td class="py-4 px-5">
                                <div class="font-semibold text-gray-900"><?php echo htmlspecialchars($row['provider']); ?></div>
                                <div class="text-xs text-gray-600 font-medium"><?php echo htmlspecialchars($acc_holder); ?></div>
                                <div class="text-xs font-mono text-gray-500"><?php echo htmlspecialchars($row['account_number']); ?></div>
                            </td>
                            <td class="py-4 px-5 text-right">
                                <span class="font-bold text-red-600 font-mono">-<?php echo number_format($row['redeem_point'], 0, ',', '.'); ?></span>
                            </td>
                            <td class="py-4 px-5 text-right">
                                <span class="font-bold text-emerald-600 font-mono">Rp <?php echo number_format($row['estimated_amount'], 0, ',', '.'); ?></span>
                            </td>
                            <td class="py-4 px-5 whitespace-nowrap text-xs text-gray-500">
                                <div><?php echo date('d M Y', strtotime($row['created_at'])); ?></div>
                                <div class="text-gray-400"><?php echo date('H:i', strtotime($row['created_at'])); ?> WIB</div>
                            </td>
                            <td class="py-4 px-5">
                                                                    <?php if ($row['status'] === 'processing'): ?>
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200">
                                            <i class="fas fa-spinner fa-spin mr-1"></i> Diproses
                                        </span>
                                    <?php elseif ($row['status'] === 'completed'): ?>
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                            <i class="fas fa-check-circle mr-1"></i> Selesai
                                        </span>
                                    <?php elseif ($row['status'] === 'rejected'): ?>
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-semibold bg-red-50 text-red-700 border border-red-200">
                                            <i class="fas fa-times-circle mr-1"></i> Ditolak
                                        </span>
                                    <?php endif; ?>
                            </td>
                            <td class="py-4 px-5 text-right whitespace-nowrap">
                                <div class="flex items-center justify-end space-x-1.5">
                                    <?php if ($row['status'] === 'processing' || $row['status'] === 'pending'): ?>
                                        <button type="button" onclick="openCompleteModal(<?php echo $row['id']; ?>, '<?php echo htmlspecialchars($trx_code); ?>')" class="inline-flex items-center px-2.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold rounded-xl shadow-sm transition duration-150">
                                            <i class="fas fa-check mr-1"></i> Selesai
                                        </button>
                                        
                                        <button type="button" onclick="openRejectModal(<?php echo $row['id']; ?>, '<?php echo htmlspecialchars($trx_code); ?>')" class="inline-flex items-center px-2.5 py-1.5 bg-red-600 hover:bg-red-700 text-white text-xs font-semibold rounded-xl shadow-sm transition duration-150">
                                            <i class="fas fa-times mr-1"></i> Tolak
                                        </button>
                                    <?php endif; ?>

                                    <a href="index.php?page=reward/detail&id=<?php echo $row['id']; ?>" class="inline-flex items-center px-2.5 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold rounded-xl transition duration-150" title="Detail">
                                        <i class="fas fa-external-link-alt"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="9" class="py-12 text-center text-gray-400">
                                <i class="fas fa-inbox text-4xl mb-3 block"></i>
                                Tidak ada data penukaran poin untuk filter yang dipilih.
                            </td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>


<!-- Complete Modal -->
<div id="completeModal" class="fixed inset-0 bg-black/50 z-50 hidden items-center justify-center p-4 backdrop-blur-sm">
    <div class="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-gray-100 transform transition-all">
        <div class="flex items-center justify-between pb-4 border-b border-gray-100">
            <div class="flex items-center space-x-2 text-emerald-600 font-bold text-lg">
                <i class="fas fa-check-circle"></i>
                <span>Selesaikan Penukaran</span>
            </div>
            <button onclick="closeCompleteModal()" type="button" class="text-gray-400 hover:text-gray-600 p-1">
                <i class="fas fa-times text-lg"></i>
            </button>
        </div>
        
        <form method="POST" action="index.php?page=reward/index" class="mt-4 space-y-4" enctype="multipart/form-data" onsubmit="return validateCompleteForm();">
            <input type="hidden" name="action_type" value="complete">
            <input type="hidden" name="redemption_id" id="complete_redemption_id" value="">
            
            <p class="text-xs text-gray-500">
                Menyelesaikan transaksi <strong id="complete_trx_code" class="text-gray-700 font-mono"></strong>.<br>
                Poin akan dipotong permanen dan warga akan menerima notifikasi penyelesaian.
            </p>
            
            <div>
                <label class="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">Bukti Transfer (Wajib Diisi) <span class="text-red-500">*</span></label>
                <input type="file" name="transfer_proof" id="transfer_proof_input" accept="image/jpeg,image/png,image/jpg" required class="w-full px-4 py-3 rounded-2xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm text-gray-800">
                <p class="text-[10px] text-gray-400 mt-1">Format didukung: JPG, PNG, JPEG.</p>
            </div>
            
            <div class="flex items-center justify-end space-x-3 pt-3">
                <button type="button" onclick="closeCompleteModal()" class="px-5 py-2.5 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-100 transition duration-150">
                    Batal
                </button>
                <button type="submit" class="px-5 py-2.5 rounded-xl text-sm font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-md shadow-emerald-500/20 transition duration-150">
                    Konfirmasi Selesai
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openCompleteModal(id, trxCode) {
    document.getElementById('complete_redemption_id').value = id;
    document.getElementById('complete_trx_code').textContent = trxCode;
    document.getElementById('transfer_proof_input').value = '';
    const modal = document.getElementById('completeModal');
    modal.classList.remove('hidden');
    modal.classList.add('flex');
}

function closeCompleteModal() {
    const modal = document.getElementById('completeModal');
    modal.classList.remove('flex');
    modal.classList.add('hidden');
}

function validateCompleteForm() {
    const file = document.getElementById('transfer_proof_input').files[0];
    if (!file) {
        alert('Peringatan: Bukti transfer wajib diunggah!');
        return false;
    }
    return confirm('Konfirmasi penukaran SELESAI? Dana akan ditransfer dan poin dipotong permanen.');
}
</script>

<!-- Material Design 3 Modal Dialog for Rejection -->
<div id="rejectModal" class="fixed inset-0 bg-black/50 z-50 hidden items-center justify-center p-4 backdrop-blur-sm">
    <div class="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-gray-100 transform transition-all">
        <div class="flex items-center justify-between pb-4 border-b border-gray-100">
            <div class="flex items-center space-x-2 text-red-600 font-bold text-lg">
                <i class="fas fa-exclamation-triangle"></i>
                <span>Reject Redemption</span>
            </div>
            <button onclick="closeRejectModal()" class="text-gray-400 hover:text-gray-600 p-1">
                <i class="fas fa-times text-lg"></i>
            </button>
        </div>
        
        <form method="POST" class="mt-4 space-y-4" onsubmit="return validateRejectForm();">
            <input type="hidden" name="action_type" value="reject">
            <input type="hidden" name="redemption_id" id="modal_redemption_id" value="">
            
            <p class="text-xs text-gray-500">
                Anda akan menolak permintaan penukaran <strong id="modal_trx_code" class="text-gray-800"></strong>.
                Poin akan dikembalikan secara otomatis 100% ke saldo aktif warga.
            </p>
            
            <div>
                <label class="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">Reject Reason (Wajib Diisi) <span class="text-red-500">*</span></label>
                <textarea name="reject_reason" id="reject_reason_input" rows="3" required placeholder="Masukkan alasan penolakan secara jelas (contoh: Nomor rekening tidak valid / e-wallet tidak aktif)..." class="w-full px-4 py-3 rounded-2xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-red-500 text-sm text-gray-800"></textarea>
            </div>
            
            <div class="flex items-center justify-end space-x-3 pt-3">
                <button type="button" onclick="closeRejectModal()" class="px-5 py-2.5 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-100 transition duration-150">
                    Batal
                </button>
                <button type="submit" class="px-5 py-2.5 rounded-xl text-sm font-semibold bg-red-600 hover:bg-red-700 text-white shadow-md shadow-red-500/20 transition duration-150">
                    Konfirmasi Reject
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openRejectModal(id, trxCode) {
    document.getElementById('modal_redemption_id').value = id;
    document.getElementById('modal_trx_code').innerText = trxCode;
    document.getElementById('reject_reason_input').value = '';
    const modal = document.getElementById('rejectModal');
    modal.classList.remove('hidden');
    modal.classList.add('flex');
}

function closeRejectModal() {
    const modal = document.getElementById('rejectModal');
    modal.classList.remove('flex');
    modal.classList.add('hidden');
}

function validateRejectForm() {
    const val = document.getElementById('reject_reason_input').value.trim();
    if (!val) {
        alert('Peringatan: Reject Reason (Alasan Penolakan) wajib diisi demi transparansi ke warga!');
        return false;
    }
    return confirm('Anda yakin menolak penukaran ini dan mengembalikan poin ke warga?');
}
</script>
