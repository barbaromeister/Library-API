// Admin Dashboard JavaScript
class AdminDashboard {
    constructor() {
        this.authURL = '/api/auth';
        this.adminURL = '/api/test';
        this.booksURL = '/api/books';
        this.currentUser = null;
        this.init();
    }

    init() {
        this.bindEvents();
        this.checkAdminAuth();
    }

    bindEvents() {
        // Navigation tabs
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const tab = e.target.closest('.nav-btn').dataset.tab;
                this.switchTab(tab);
            });
        });

        // Refresh buttons
        document.getElementById('refreshUsers').addEventListener('click', () => {
            this.loadUsers();
        });

        document.getElementById('refreshBooks').addEventListener('click', () => {
            this.loadBooks();
        });

        // Logout
        document.getElementById('adminLogout').addEventListener('click', () => {
            this.logout();
        });

        // Back to library
        document.getElementById('backToLibrary').addEventListener('click', () => {
            window.location.href = '/';
        });

        // Admin login form
        document.getElementById('adminLoginForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleAdminLogin();
        });
    }

    async checkAdminAuth() {
        try {
            const response = await fetch(`${this.authURL}/me`, {
                credentials: 'include'
            });
            
            if (response.ok) {
                const data = await response.json();
                if (data.success && data.role === 'ADMIN') {
                    this.currentUser = data;
                    this.showAdminDashboard();
                } else {
                    this.showAdminLogin();
                }
            } else {
                this.showAdminLogin();
            }
        } catch (error) {
            console.error('Auth check failed:', error);
            this.showAdminLogin();
        }
    }

    showAdminDashboard() {
        document.getElementById('adminLoginModal').style.display = 'none';
        document.getElementById('adminWelcome').textContent = `Welcome, ${this.currentUser.username}`;
        
        // Load initial data
        this.loadUsers();
        this.loadBooks();
        this.loadStats();
    }

    showAdminLogin() {
        document.getElementById('adminLoginModal').style.display = 'flex';
    }

    async handleAdminLogin() {
        const form = document.getElementById('adminLoginForm');
        const formData = new FormData(form);
        
        try {
            const response = await fetch(`${this.authURL}/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                credentials: 'include',
                body: JSON.stringify({
                    username: formData.get('username'),
                    password: formData.get('password')
                })
            });
            
            const data = await response.json();
            
            if (data.success) {
                if (data.role === 'ADMIN') {
                    this.currentUser = data;
                    this.showAdminDashboard();
                    this.showToast('success', 'Admin login successful');
                } else {
                    this.showToast('error', 'Access denied', 'Admin privileges required');
                }
            } else {
                this.showToast('error', 'Login failed', data.message);
            }
        } catch (error) {
            console.error('Login error:', error);
            this.showToast('error', 'Login failed', 'Network error occurred');
        }
    }

    async logout() {
        try {
            await fetch(`${this.authURL}/logout`, {
                method: 'POST',
                credentials: 'include'
            });
            
            this.currentUser = null;
            this.showAdminLogin();
            this.showToast('success', 'Logged out successfully');
        } catch (error) {
            console.error('Logout error:', error);
        }
    }

    switchTab(tabName) {
        // Update nav buttons
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

        // Update tab content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById(`${tabName}-tab`).classList.add('active');

        // Load data for the active tab
        if (tabName === 'users') {
            this.loadUsers();
        } else if (tabName === 'books') {
            this.loadBooks();
        } else if (tabName === 'stats') {
            this.loadStats();
        }
    }

    async loadUsers() {
        try {
            const tbody = document.getElementById('usersTableBody');
            tbody.innerHTML = '<tr><td colspan="6" class="loading-cell"><i class="fas fa-spinner fa-spin"></i> Loading users...</td></tr>';

            const response = await fetch(`${this.adminURL}/admin/users`, {
                credentials: 'include'
            });
            
            if (response.ok) {
                const users = await response.json();
                this.renderUsers(users);
            } else {
                throw new Error('Failed to load users');
            }
        } catch (error) {
            console.error('Error loading users:', error);
            const tbody = document.getElementById('usersTableBody');
            tbody.innerHTML = '<tr><td colspan="6" class="loading-cell">Failed to load users</td></tr>';
            this.showToast('error', 'Failed to load users');
        }
    }

    renderUsers(users) {
        const tbody = document.getElementById('usersTableBody');
        
        if (users.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="loading-cell">No users found</td></tr>';
            return;
        }

        tbody.innerHTML = users.map(user => `
            <tr>
                <td>${user.id}</td>
                <td>${user.username}</td>
                <td>${user.email}</td>
                <td>
                    <span class="role-badge ${user.role.toLowerCase()}">
                        ${user.role}
                    </span>
                </td>
                <td>${new Date(user.createdAt).toLocaleDateString()}</td>
                <td>
                    <div class="action-buttons">
                        <button class="btn btn-sm btn-warning" onclick="adminDashboard.editUser(${user.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="adminDashboard.deleteUser(${user.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');
    }

    async loadBooks() {
        try {
            const tbody = document.getElementById('booksTableBody');
            tbody.innerHTML = '<tr><td colspan="6" class="loading-cell"><i class="fas fa-spinner fa-spin"></i> Loading books...</td></tr>';

            const response = await fetch(this.booksURL);
            
            if (response.ok) {
                const books = await response.json();
                this.renderBooks(books);
            } else {
                throw new Error('Failed to load books');
            }
        } catch (error) {
            console.error('Error loading books:', error);
            const tbody = document.getElementById('booksTableBody');
            tbody.innerHTML = '<tr><td colspan="6" class="loading-cell">Failed to load books</td></tr>';
            this.showToast('error', 'Failed to load books');
        }
    }

    renderBooks(books) {
        const tbody = document.getElementById('booksTableBody');
        
        if (books.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="loading-cell">No books found</td></tr>';
            return;
        }

        tbody.innerHTML = books.map(book => `
            <tr>
                <td>${book.id}</td>
                <td>${book.title}</td>
                <td>${book.author}</td>
                <td>${book.isbn || '-'}</td>
                <td>${book.pageCount || '-'}</td>
                <td>
                    <div class="action-buttons">
                        <button class="btn btn-sm btn-warning" onclick="adminDashboard.editBook(${book.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="adminDashboard.deleteBook(${book.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');
    }

    async loadStats() {
        try {
            // Load users for stats
            const usersResponse = await fetch(`${this.adminURL}/users`, {
                credentials: 'include'
            });
            
            const booksResponse = await fetch(this.booksURL);

            if (usersResponse.ok && booksResponse.ok) {
                const users = await usersResponse.json();
                const books = await booksResponse.json();

                // Calculate stats
                const totalUsers = users.length;
                const adminUsers = users.filter(user => user.role === 'ADMIN').length;
                const totalBooks = books.length;
                
                // Recent registrations (last 7 days)
                const sevenDaysAgo = new Date();
                sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
                const recentUsers = users.filter(user => 
                    new Date(user.createdAt) > sevenDaysAgo
                ).length;

                // Update UI
                document.getElementById('totalUsersCount').textContent = totalUsers;
                document.getElementById('adminUsersCount').textContent = adminUsers;
                document.getElementById('totalBooksCount').textContent = totalBooks;
                document.getElementById('recentRegistrations').textContent = recentUsers;
            }
        } catch (error) {
            console.error('Error loading stats:', error);
            this.showToast('error', 'Failed to load statistics');
        }
    }

    // Placeholder functions for future implementation
    editUser(userId) {
        this.showToast('info', 'Feature coming soon', `Edit user ${userId}`);
    }

    deleteUser(userId) {
        this.showToast('info', 'Feature coming soon', `Delete user ${userId}`);
    }

    editBook(bookId) {
        this.showToast('info', 'Feature coming soon', `Edit book ${bookId}`);
    }

    deleteBook(bookId) {
        this.showToast('info', 'Feature coming soon', `Delete book ${bookId}`);
    }

    showToast(type, title, message = '') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;

        const iconMap = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle'
        };

        toast.innerHTML = `
            <div class="toast-icon">
                <i class="${iconMap[type]}"></i>
            </div>
            <div class="toast-content">
                <h4>${title}</h4>
                ${message ? `<p>${message}</p>` : ''}
            </div>
        `;

        container.appendChild(toast);

        // Auto remove after 5 seconds
        setTimeout(() => {
            toast.style.animation = 'slideInRight 0.3s ease reverse';
            setTimeout(() => {
                if (container.contains(toast)) {
                    container.removeChild(toast);
                }
            }, 300);
        }, 5000);
    }
}

// Initialize admin dashboard
document.addEventListener('DOMContentLoaded', () => {
    window.adminDashboard = new AdminDashboard();
});