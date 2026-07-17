<?php
// modules/reward/detail.php
// Admin Detail & Audit Log for Reward Redemption
check_user_level(['admin']);

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if (!$id) {
    echo "<script>alert('ID tidak ditemukan!'); window.location.href='index.php?page=reward/index';</script>";
    exit;
}

// Handle action submit from detail page
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action_type'])) {
    $action_type = $_POST['action_type'];
    $admin_id = (int)$_SESSION['user_id'];
    
    $stmt_g = mysqli_prepare($koneksi, "SELECT * FROM reward_redemptions WHERE id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt_g, "i", $id);
    mysqli_stmt_execute($stmt_g);
    $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_g));
    mysqli_stmt_close($stmt_g);
    
    if ($row) {
        $old_status = $row['status'];
        $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);
        $uid = (int)$row['user_id'];
        $pts = (int)$row['redeem_point'];
        
        if ($action_type === 'process' && $old_status === 'pending') {
            $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'processing', processed_at = NOW(), admin_id = ? WHERE id = ?");
            mysqli_stmt_bind_param($stmt, "ii", $admin_id, $id);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_close($stmt);
            
            mysqli_query($koneksi, "INSERT INTO redemption_audit_logs (redemption_id, transaction_code, action, old_status, new_status, admin_id, reason, created_at) VALUES ($id, '$trx_code', 'PROCESS', '$old_status', 'processing', $admin_id, 'Admin memproses dari halaman detail', NOW())");
            mysqli_query($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES ($uid, 'Tukar Poin Diproses', 'Admin sedang memproses penukaran poin Anda. Kode: $trx_code', 'info')");
            
            echo "<script>alert('Berhasil diproses! Status berubah menjadi Processing.'); window.location.href='index.php?page=reward/detail&id=$id';</script>";
            exit;
        }
        
        if ($action_type === 'complete' && ($old_status === 'processing' || $old_status === 'pending')) {
            mysqli_begin_transaction($koneksi);
            try {
                if ($old_status !== 'completed' && $old_status !== 'rejected') {
                    mysqli_query($koneksi, "UPDATE pengguna SET reserved_saldo = GREATEST(0, COALESCE(reserved_saldo, 0) - $pts) WHERE id_pengguna = $uid");
                }
                
                $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'completed', completed_at = NOW(), admin_id = ? WHERE id = ?");
                mysqli_stmt_bind_param($stmt, "ii", $admin_id, $id);
                mysqli_stmt_execute($stmt);
                mysqli_stmt_close($stmt);
                
                mysqli_query($koneksi, "INSERT INTO redemption_audit_logs (redemption_id, transaction_code, action, old_status, new_status, admin_id, reason, created_at) VALUES ($id, '$trx_code', 'COMPLETE', '$old_status', 'completed', $admin_id, 'Penukaran diselesaikan dari halaman detail', NOW())");
                mysqli_query($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES ($uid, 'Tukar Poin Berhasil', 'Penukaran poin berhasil. Kode: $trx_code', 'success')");
                
                mysqli_commit($koneksi);
                echo "<script>alert('Penukaran berhasil selesai (Completed)!'); window.location.href='index.php?page=reward/detail&id=$id';</script>";
                exit;
            } catch (Exception $e) {
                mysqli_rollback($koneksi);
            }
        }
        
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
                
                $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'rejected', admin_note = ?, completed_at = NOW(), admin_id = ? WHERE id = ?");
                mysqli_stmt_bind_param($stmt, "sii", $note, $admin_id, $id);
                mysqli_stmt_execute($stmt);
                mysqli_stmt_close($stmt);
                
                $safe_note = mysqli_real_escape_string($koneksi, $note);
                mysqli_query($koneksi, "INSERT INTO redemption_audit_logs (redemption_id, transaction_code, action, old_status, new_status, admin_id, reason, created_at) VALUES ($id, '$trx_code', 'REJECT', '$old_status', 'rejected', $admin_id, '$safe_note', NOW())");
                mysqli_query($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES ($uid, 'Tukar Poin Ditolak', 'Penukaran poin ditolak. Alasan: $safe_note. Kode: $trx_code', 'warning')");
                
                mysqli_commit($koneksi);
                echo "<script>alert('Penukaran berhasil DITOLAK dan poin dikembalikan 100%!'); window.location.href='index.php?page=reward/detail&id=$id';</script>";
                exit;
            } catch (Exception $e) {
                mysqli_rollback($koneksi);
            }
        }
    }
}

$stmt = mysqli_prepare($koneksi, "SELECT r.*, u.nama_lengkap as nama_warga, u.no_telepon as telp_warga, u.username, a.nama_lengkap as nama_admin 
                                  FROM reward_redemptions r 
                                  JOIN pengguna u ON r.user_id = u.id_pengguna 
                                  LEFT JOIN pengguna a ON r.admin_id = a.id_pengguna 
                                  WHERE r.id = ? LIMIT 1");
mysqli_stmt_bind_param($stmt, "i", $id);
mysqli_stmt_execute($stmt);
$row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
mysqli_stmt_close($stmt);

if (!$row) {
    echo "<script>alert('Data penukaran tidak ditemukan.'); window.location.href='index.php?page=reward/index';</script>";
    exit;
}

$trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);
$acc_holder = $row['account_holder_name'] ?: $row['account_name'];

// Fetch Audit Logs
$logs = [];
$stmt_l = mysqli_prepare($koneksi, "SELECT l.*, p.nama_lengkap as admin_name FROM redemption_audit_logs l LEFT JOIN pengguna p ON l.admin_id = p.id_pengguna WHERE l.redemption_id = ? ORDER BY l.created_at ASC");
mysqli_stmt_bind_param($stmt_l, "i", $id);
mysqli_stmt_execute($stmt_l);
$res_l = mysqli_stmt_get_result($stmt_l);
while ($lg = mysqli_fetch_assoc($res_l)) {
    $logs[] = $lg;
}
mysqli_stmt_close($stmt_l);
?>

<div class="space-y-6 max-w-5xl mx-auto">
    <!-- Top Action / Breadcrumb -->
    <div class="flex items-center justify-between">
        <a href="index.php?page=reward/index" class="inline-flex items-center text-sm font-semibold text-emerald-600 hover:text-emerald-700">
            <i class="fas fa-arrow-left mr-2"></i> Kembali ke Daftar Tukar Poin
        </a>
        <div class="text-xs text-gray-500 font-mono">ID Internal: #<?php echo $row['id']; ?></div>
    </div>

    <!-- Header Card -->
    <div class="bg-white rounded-3xl p-6 md:p-8 shadow-sm border border-gray-100 flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
            <div class="flex items-center space-x-3 mb-2">
                <span class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-gray-100 text-gray-700">
                    <?php echo htmlspecialchars($row['destination_type']); ?>
                </span>
                <?php if ($row['status'] === 'pending'): ?>
                    <span class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-amber-100 text-amber-800">Pending</span>
                <?php elseif ($row['status'] === 'processing'): ?>
                    <span class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-blue-100 text-blue-800 animate-pulse">Processing</span>
                <?php elseif ($row['status'] === 'completed'): ?>
                    <span class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-emerald-100 text-emerald-800">Completed</span>
                <?php elseif ($row['status'] === 'rejected'): ?>
                    <span class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-red-100 text-red-800">Rejected</span>
                <?php endif; ?>
            </div>
            <h1 class="text-3xl font-extrabold text-gray-900 font-mono tracking-tight"><?php echo htmlspecialchars($trx_code); ?></h1>
            <p class="text-sm text-gray-500 mt-1">Diajukan pada <?php echo date('d F Y, H:i:s', strtotime($row['created_at'])); ?> WIB</p>
        </div>

        <!-- Material 3 Action Buttons in Detail View -->
        <div class="flex items-center space-x-3">
            <?php if ($row['status'] === 'pending'): ?>
                <form method="POST" onsubmit="return confirm('Proses penukaran ini ke status Processing?');">
                    <input type="hidden" name="action_type" value="process">
                    <button type="submit" class="px-5 py-2.5 rounded-2xl bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm shadow-md shadow-blue-500/20 transition duration-150 inline-flex items-center">
                        <i class="fas fa-play mr-2"></i> Process Redemption
                    </button>
                </form>
            <?php endif; ?>

            <?php if ($row['status'] === 'processing' || $row['status'] === 'pending'): ?>
                <form method="POST" onsubmit="return confirm('Konfirmasi penukaran SELESAI? Dana akan ditransfer dan poin dipotong permanen.');">
                    <input type="hidden" name="action_type" value="complete">
                    <button type="submit" class="px-5 py-2.5 rounded-2xl bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-sm shadow-md shadow-emerald-500/20 transition duration-150 inline-flex items-center">
                        <i class="fas fa-check-circle mr-2"></i> Complete & Send
                    </button>
                </form>
                
                <button type="button" onclick="openRejectDetailModal()" class="px-5 py-2.5 rounded-2xl bg-red-600 hover:bg-red-700 text-white font-semibold text-sm shadow-md shadow-red-500/20 transition duration-150 inline-flex items-center">
                    <i class="fas fa-times-circle mr-2"></i> Reject Request
                </button>
            <?php endif; ?>
        </div>
    </div>

    <!-- Detail Grid Layout -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Left: Citizen Info & Account Details -->
        <div class="md:col-span-2 space-y-6">
            <!-- Target Pencairan -->
            <div class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
                <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Informasi Rekening / E-Wallet Tujuan</h3>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div class="p-4 rounded-2xl bg-gray-50 border border-gray-100">
                        <div class="text-xs text-gray-500 font-medium">Bank / E-Wallet Provider</div>
                        <div class="text-lg font-bold text-gray-900 mt-0.5"><?php echo htmlspecialchars($row['provider']); ?></div>
                    </div>
                    <div class="p-4 rounded-2xl bg-gray-50 border border-gray-100">
                        <div class="text-xs text-gray-500 font-medium">Nomor Rekening / E-Wallet</div>
                        <div class="text-lg font-bold text-emerald-600 font-mono mt-0.5"><?php echo htmlspecialchars($row['account_number']); ?></div>
                    </div>
                    <div class="p-4 rounded-2xl bg-gray-50 border border-gray-100 sm:col-span-2">
                        <div class="text-xs text-gray-500 font-medium">Nama Pemilik Rekening (Account Holder)</div>
                        <div class="text-base font-bold text-gray-800 mt-0.5"><?php echo htmlspecialchars($acc_holder); ?></div>
                    </div>
                </div>
            </div>

            <!-- Informasi Warga -->
            <div class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
                <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Informasi Warga Pemohon</h3>
                <div class="flex items-center space-x-4 p-4 rounded-2xl bg-emerald-50/50 border border-emerald-100">
                    <div class="w-12 h-12 rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold text-lg">
                        <?php echo strtoupper(substr($row['nama_warga'], 0, 1)); ?>
                    </div>
                    <div>
                        <div class="font-bold text-gray-900 text-base"><?php echo htmlspecialchars($row['nama_warga']); ?></div>
                        <div class="text-xs text-gray-500">ID Warga: #<?php echo $row['user_id']; ?> · Username: <?php echo htmlspecialchars($row['username']); ?></div>
                        <div class="text-xs text-emerald-700 font-medium mt-1"><i class="fas fa-phone mr-1"></i> <?php echo htmlspecialchars($row['telp_warga']); ?></div>
                    </div>
                </div>
            </div>

            <!-- Admin Note (If Rejected) -->
            <?php if (!empty($row['admin_note'])): ?>
            <div class="bg-red-50 rounded-3xl p-6 border border-red-100">
                <h3 class="text-xs font-bold text-red-600 uppercase tracking-wider mb-2"><i class="fas fa-info-circle mr-1"></i> Alasan / Catatan Admin</h3>
                <p class="text-sm text-red-800 font-medium leading-relaxed"><?php echo nl2br(htmlspecialchars($row['admin_note'])); ?></p>
            </div>
            <?php endif; ?>
        </div>

        <!-- Right: Summary Points & Audit Logs -->
        <div class="space-y-6">
            <!-- Financial Summary -->
            <div class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
                <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Ringkasan Penukaran</h3>
                <div class="space-y-4">
                    <div class="flex items-center justify-between py-2 border-b border-gray-100">
                        <span class="text-sm text-gray-600">Poin Ditukar</span>
                        <span class="text-base font-bold text-red-600">-<?php echo number_format($row['redeem_point'], 0, ',', '.'); ?> Poin</span>
                    </div>
                    <div class="flex items-center justify-between py-2 border-b border-gray-100">
                        <span class="text-sm text-gray-600">Kurs Konversi</span>
                        <span class="text-sm font-semibold text-gray-800">1 Poin = Rp <?php echo $row['conversion_rate']; ?></span>
                    </div>
                    <div class="flex items-center justify-between pt-2">
                        <span class="text-sm font-bold text-gray-800">Total Pencairan (Rp)</span>
                        <span class="text-xl font-extrabold text-emerald-600">Rp <?php echo number_format($row['estimated_amount'], 0, ',', '.'); ?></span>
                    </div>
                </div>
            </div>

            <!-- Timeline & Status Log -->
            <div class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
                <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Timeline & Audit Trail</h3>
                <div class="space-y-4 text-xs">
                    <div class="flex items-start space-x-3">
                        <div class="w-2 h-2 rounded-full bg-amber-500 mt-1.5 shrink-0"></div>
                        <div>
                            <div class="font-bold text-gray-800">Permintaan Diajukan (Submitted)</div>
                            <div class="text-gray-400 mt-0.5"><?php echo date('d M Y, H:i:s', strtotime($row['created_at'])); ?></div>
                        </div>
                    </div>

                    <?php if (!empty($row['processed_at'])): ?>
                    <div class="flex items-start space-x-3">
                        <div class="w-2 h-2 rounded-full bg-blue-500 mt-1.5 shrink-0"></div>
                        <div>
                            <div class="font-bold text-gray-800">Mulai Diproses (Processing)</div>
                            <div class="text-gray-400 mt-0.5"><?php echo date('d M Y, H:i:s', strtotime($row['processed_at'])); ?></div>
                        </div>
                    </div>
                    <?php endif; ?>

                    <?php if (!empty($row['completed_at'])): ?>
                    <div class="flex items-start space-x-3">
                        <div class="w-2 h-2 rounded-full <?php echo ($row['status']=='completed') ? 'bg-emerald-500' : 'bg-red-500'; ?> mt-1.5 shrink-0"></div>
                        <div>
                            <div class="font-bold text-gray-800"><?php echo ($row['status']=='completed') ? 'Selesai (Completed)' : 'Ditolak (Rejected)'; ?></div>
                            <div class="text-gray-400 mt-0.5"><?php echo date('d M Y, H:i:s', strtotime($row['completed_at'])); ?></div>
                            <?php if (!empty($row['nama_admin'])): ?>
                                <div class="text-emerald-700 mt-0.5">Oleh Admin: <?php echo htmlspecialchars($row['nama_admin']); ?></div>
                            <?php endif; ?>
                        </div>
                    </div>
                    <?php endif; ?>

                    <?php if (!empty($logs)): ?>
                    <div class="pt-3 border-t border-gray-100">
                        <div class="font-bold text-gray-600 uppercase mb-2">Riwayat Audit Sistem:</div>
                        <?php foreach ($logs as $lg): ?>
                            <div class="p-2.5 rounded-xl bg-gray-50 border border-gray-100 mb-2">
                                <div class="flex justify-between font-bold text-gray-700">
                                    <span><?php echo htmlspecialchars($lg['action']); ?></span>
                                    <span class="text-gray-400"><?php echo date('d/m H:i', strtotime($lg['created_at'])); ?></span>
                                </div>
                                <?php if (!empty($lg['reason'])): ?>
                                    <div class="text-gray-600 mt-1 italic">"<?php echo htmlspecialchars($lg['reason']); ?>"</div>
                                <?php endif; ?>
                                <?php if (!empty($lg['admin_name'])): ?>
                                    <div class="text-gray-400 mt-1">Oleh: <?php echo htmlspecialchars($lg['admin_name']); ?></div>
                                <?php endif; ?>
                            </div>
                        <?php endforeach; ?>
                    </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Reject untuk halaman detail -->
<div id="rejectDetailModal" class="fixed inset-0 bg-black/50 z-50 hidden items-center justify-center p-4 backdrop-blur-sm">
    <div class="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-gray-100">
        <div class="flex items-center justify-between pb-4 border-b border-gray-100">
            <div class="flex items-center space-x-2 text-red-600 font-bold text-lg">
                <i class="fas fa-exclamation-triangle"></i>
                <span>Reject Redemption #<?php echo $id; ?></span>
            </div>
            <button onclick="closeRejectDetailModal()" class="text-gray-400 hover:text-gray-600 p-1">
                <i class="fas fa-times text-lg"></i>
            </button>
        </div>
        
        <form method="POST" class="mt-4 space-y-4" onsubmit="return validateRejectDetailForm();">
            <input type="hidden" name="action_type" value="reject">
            
            <p class="text-xs text-gray-500">
                Poin penukaran akan dikembalikan secara penuh (100%) ke saldo aktif warga, dan notifikasi beserta alasan penolakan akan dikirim.
            </p>
            
            <div>
                <label class="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">Reject Reason (Wajib Diisi) <span class="text-red-500">*</span></label>
                <textarea name="reject_reason" id="reject_reason_detail_input" rows="3" required placeholder="Alasan penolakan..." class="w-full px-4 py-3 rounded-2xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-red-500 text-sm text-gray-800"></textarea>
            </div>
            
            <div class="flex items-center justify-end space-x-3 pt-3">
                <button type="button" onclick="closeRejectDetailModal()" class="px-5 py-2.5 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-100">
                    Batal
                </button>
                <button type="submit" class="px-5 py-2.5 rounded-xl text-sm font-semibold bg-red-600 hover:bg-red-700 text-white shadow-md shadow-red-500/20">
                    Konfirmasi Reject
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openRejectDetailModal() {
    document.getElementById('reject_reason_detail_input').value = '';
    const modal = document.getElementById('rejectDetailModal');
    modal.classList.remove('hidden');
    modal.classList.add('flex');
}

function closeRejectDetailModal() {
    const modal = document.getElementById('rejectDetailModal');
    modal.classList.remove('flex');
    modal.classList.add('hidden');
}

function validateRejectDetailForm() {
    const val = document.getElementById('reject_reason_detail_input').value.trim();
    if (!val) {
        alert('Peringatan: Reject Reason wajib diisi demi transparansi ke warga!');
        return false;
    }
    return confirm('Anda yakin menolak penukaran ini dan mengembalikan poin ke warga?');
}
</script>
