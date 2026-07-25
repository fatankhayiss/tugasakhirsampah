<?php // includes/footer.php ?>
            </main> <?php if (is_logged_in()): ?>
        </div> </div> <?php else: // Kondisi jika pengguna tidak login (misalnya di halaman login) ?>
    </div> <?php endif; // Akhir dari if (is_logged_in()) untuk penutup div layout utama ?>

<footer class="text-center py-4 <?php echo is_logged_in() ? 'footer-admin-logged-in md:pl-64' : ''; ?> bg-gray-200 text-gray-600 text-sm print:hidden" <?php echo is_logged_in() ? 'style="padding-left: 256px;"' : ''; ?>>
    <p>&copy; <?php echo date('Y'); ?> ITrashy Bank Sampah Digital. Dibuat dengan <i class="fas fa-heart text-red-500"></i>.</p>
</footer>

<script>
// Logika scroll pintar untuk Footer agar saat scroll ke atas, footer tersembunyi (naik) lebih dulu sebelum konten utama
document.addEventListener('DOMContentLoaded', function() {
    window.addEventListener('wheel', function(e) {
        // Jika sedang scroll ke ATAS (e.deltaY < 0)
        if (e.deltaY < 0) {
            // Cek apakah halaman luar sedang terscroll ke bawah (footer sedang terlihat/muncul)
            if (window.scrollY > 0 || document.documentElement.scrollTop > 0) {
                // Cegah scroll pada elemen tabel dalam (<main>) agar tidak naik duluan
                e.preventDefault();
                // Prioritaskan scroll ke atas pada jendela luar terlebih dahulu untuk menyembunyikan footer
                window.scrollBy(0, e.deltaY);
            }
        }
    }, { passive: false });
});
</script>

<script src="https://cdn.jsdelivr.net/gh/alpinejs/alpine@v2.x.x/dist/alpine.min.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<?php if (isset($_SESSION['success_message'])): ?>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        Swal.fire({
            icon: 'success',
            title: 'Sukses!',
            text: '<?php echo addslashes($_SESSION['success_message']); ?>',
            confirmButtonColor: '#3085d6',
            timer: 3000,
            timerProgressBar: true
        });
    });
</script>
<?php unset($_SESSION['success_message']); ?>
<?php endif; ?>

<?php if (isset($_SESSION['error_message'])): ?>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: '<?php echo addslashes($_SESSION['error_message']); ?>',
            confirmButtonColor: '#d33'
        });
    });
</script>
<?php unset($_SESSION['error_message']); ?>
<?php endif; ?>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const deleteButtons = document.querySelectorAll('.btn-hapus');
        deleteButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const url = this.getAttribute('href');
                const pesan = this.getAttribute('data-pesan') || 'Apakah Anda yakin ingin menghapus data ini?';
                
                Swal.fire({
                    title: 'Konfirmasi Hapus',
                    text: pesan,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#3085d6',
                    confirmButtonText: 'Ya, Hapus!',
                    cancelButtonText: 'Batal'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = url;
                    }
                });
            });
        });

        const confirmForms = document.querySelectorAll('.form-confirm');
        confirmForms.forEach(form => {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                const title = this.getAttribute('data-title') || 'Konfirmasi';
                const text = this.getAttribute('data-text') || 'Apakah Anda yakin ingin melanjutkan?';
                
                Swal.fire({
                    title: title,
                    text: text,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Ya, Lanjutkan!',
                    cancelButtonText: 'Batal'
                }).then((result) => {
                    if (result.isConfirmed) {
                        form.submit();
                    }
                });
            });
        });

        // Global Handler untuk Custom Form Validation (Menggantikan Tooltip Native Browser)
        let isShowingValidationError = false;
        document.addEventListener('invalid', function(e) {
            e.preventDefault(); // Mencegah popup native browser yang jelek
            
            const field = e.target;
            field.classList.add('border-red-500', 'ring-2', 'ring-red-500', 'transition-all');
            setTimeout(() => {
                field.classList.remove('border-red-500', 'ring-2', 'ring-red-500');
            }, 3000);

            if (!isShowingValidationError) {
                isShowingValidationError = true;
                
                let fieldName = field.getAttribute('placeholder') || field.getAttribute('name') || 'Kolom ini';
                const label = document.querySelector(`label[for="${field.id}"]`) || field.closest('div')?.querySelector('label');
                if (label && label.innerText) {
                    fieldName = label.innerText.replace(/\*/g, '').trim();
                }

                let pesanError = 'Kolom ini wajib diisi dengan benar.';
                if (field.validity.valueMissing) {
                    pesanError = `${fieldName} wajib diisi dan tidak boleh kosong!`;
                } else if (field.validity.typeMismatch) {
                    pesanError = `Format pada ${fieldName} tidak valid!`;
                } else if (field.validity.rangeUnderflow || field.validity.rangeOverflow || field.validity.stepMismatch) {
                    pesanError = `Nilai pada ${fieldName} tidak sesuai ketentuan!`;
                } else if (field.validity.tooShort || field.validity.tooLong) {
                    pesanError = `Panjang teks ${fieldName} tidak memenuhi syarat!`;
                } else if (field.validationMessage) {
                    pesanError = field.validationMessage;
                }

                Swal.fire({
                    toast: true,
                    position: 'top-end',
                    icon: 'warning',
                    title: 'Kolom Belum Lengkap',
                    text: pesanError,
                    showConfirmButton: false,
                    timer: 3500,
                    timerProgressBar: true,
                    didOpen: (toast) => {
                        toast.addEventListener('mouseenter', Swal.stopTimer);
                        toast.addEventListener('mouseleave', Swal.resumeTimer);
                    }
                });

                field.focus();
                setTimeout(() => {
                    isShowingValidationError = false;
                }, 600);
            }
        }, true);

        document.addEventListener('input', function(e) {
            if (e.target && e.target.classList && e.target.classList.contains('border-red-500')) {
                e.target.classList.remove('border-red-500', 'ring-2', 'ring-red-500');
            }
        }, true);
    });
</script>

<?php if (is_logged_in()): // Hanya sertakan script sidebar jika pengguna login ?>
<script>
    // Script untuk toggle sidebar di mobile
    const menuButton = document.getElementById('menu-button');
    const sidebar = document.getElementById('sidebar');
    const sidebarOverlay = document.getElementById('sidebar-overlay');
    const contentArea = document.getElementById('content-area'); // Mungkin tidak terlalu dibutuhkan lagi untuk logic ini

    function openSidebar() {
        if (sidebar && sidebarOverlay) {
            sidebar.classList.remove('-translate-x-full');
            sidebarOverlay.classList.remove('opacity-0');
            sidebarOverlay.classList.remove('pointer-events-none');
        }
    }

    function closeSidebar() {
        if (sidebar && sidebarOverlay) {
            sidebar.classList.add('-translate-x-full');
            sidebarOverlay.classList.add('opacity-0');
            sidebarOverlay.classList.add('pointer-events-none');
        }
    }

    if (menuButton) {
        menuButton.addEventListener('click', (e) => {
            e.stopPropagation();
            if (sidebar.classList.contains('-translate-x-full')) {
                openSidebar();
            } else {
                closeSidebar();
            }
        });
    }

    if (sidebarOverlay) {
        sidebarOverlay.addEventListener('click', () => {
            closeSidebar();
        });
    }

    // Menutup sidebar jika menekan tombol Escape
    document.addEventListener('keydown', (e) => {
        if (e.key === "Escape" && !sidebar.classList.contains('-translate-x-full')) {
            closeSidebar();
        }
    });

    // Auto-scroll sidebar to active link on page load
    const sidebarNav = document.querySelector('.sidebar nav');
    const activeLink = document.querySelector('.sidebar .active-nav-link');
    if (sidebarNav && activeLink) {
        // Only scroll if the link is likely out of view or far down
        const navRect = sidebarNav.getBoundingClientRect();
        const linkRect = activeLink.getBoundingClientRect();
        if (linkRect.top < navRect.top || linkRect.bottom > navRect.bottom) {
            const scrollAmount = (linkRect.top - navRect.top) - (navRect.height / 2) + (linkRect.height / 2);
            sidebarNav.scrollTop += scrollAmount;
        }
    }
</script>
<?php endif; ?>

</body>
</html>
