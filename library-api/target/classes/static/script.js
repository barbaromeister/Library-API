// Library Management System JavaScript

class LibraryManager {
    constructor() {
        this.books = [];
        this.currentView = 'grid';
        this.currentEditId = null;
        this.baseURL = '/api/books';
        this.init();
    }

    init() {
        this.bindEvents();
        this.loadBooks();
        this.updateStats();
    }

    bindEvents() {
        // Add book button
        document.getElementById('addBookBtn').addEventListener('click', () => {
            this.openModal();
        });

        // Close modal buttons
        document.getElementById('closeModal').addEventListener('click', () => {
            this.closeModal();
        });

        document.getElementById('cancelBtn').addEventListener('click', () => {
            this.closeModal();
        });

        // Book form submission
        document.getElementById('bookForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveBook();
        });

        // Search functionality
        document.getElementById('searchInput').addEventListener('input', (e) => {
            this.searchBooks(e.target.value);
        });

        document.getElementById('searchType').addEventListener('change', () => {
            const searchValue = document.getElementById('searchInput').value;
            if (searchValue) {
                this.searchBooks(searchValue);
            }
        });

        // View toggle
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.toggleView(e.target.closest('.view-btn').dataset.view);
            });
        });

        // Delete modal events
        document.getElementById('closeDeleteModal').addEventListener('click', () => {
            this.closeDeleteModal();
        });

        document.getElementById('cancelDeleteBtn').addEventListener('click', () => {
            this.closeDeleteModal();
        });

        document.getElementById('confirmDeleteBtn').addEventListener('click', () => {
            this.confirmDelete();
        });

        // Close modals when clicking outside
        window.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeModal();
                this.closeDeleteModal();
            }
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closeModal();
                this.closeDeleteModal();
            }
        });
    }

    async loadBooks() {
        try {
            this.showLoading(true);
            const response = await fetch(this.baseURL);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            this.books = await response.json();
            this.renderBooks();
            this.updateStats();
            this.showToast('success', 'Books loaded successfully');
        } catch (error) {
            console.error('Error loading books:', error);
            this.showError('Failed to load books. Please check if the server is running.');
            this.showToast('error', 'Failed to load books', error.message);
        } finally {
            this.showLoading(false);
        }
    }

    async saveBook() {
        const formData = new FormData(document.getElementById('bookForm'));
        const bookData = {
            title: formData.get('title'),
            author: formData.get('author'),
            isbn: formData.get('isbn') || null,
            publishDate: formData.get('publishDate') || null,
            pageCount: formData.get('pageCount') ? parseInt(formData.get('pageCount')) : null
        };

        // Validate required fields
        if (!bookData.title || !bookData.author) {
            this.showToast('error', 'Validation Error', 'Title and Author are required');
            return;
        }

        try {
            const url = this.currentEditId 
                ? `${this.baseURL}/${this.currentEditId}` 
                : this.baseURL;
            
            const method = this.currentEditId ? 'PUT' : 'POST';
            
            const response = await fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(bookData)
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const savedBook = await response.json();
            
            if (this.currentEditId) {
                const index = this.books.findIndex(book => book.id === this.currentEditId);
                if (index !== -1) {
                    this.books[index] = savedBook;
                }
                this.showToast('success', 'Book updated successfully');
            } else {
                this.books.push(savedBook);
                this.showToast('success', 'Book added successfully');
            }

            this.renderBooks();
            this.updateStats();
            this.closeModal();
        } catch (error) {
            console.error('Error saving book:', error);
            this.showToast('error', 'Failed to save book', error.message);
        }
    }

    async deleteBook(id) {
        try {
            const response = await fetch(`${this.baseURL}/${id}`, {
                method: 'DELETE'
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            this.books = this.books.filter(book => book.id !== id);
            this.renderBooks();
            this.updateStats();
            this.showToast('success', 'Book deleted successfully');
            this.closeDeleteModal();
        } catch (error) {
            console.error('Error deleting book:', error);
            this.showToast('error', 'Failed to delete book', error.message);
        }
    }

    async searchBooks(query) {
        if (!query.trim()) {
            this.renderBooks();
            return;
        }

        const searchType = document.getElementById('searchType').value;
        
        try {
            let searchUrl;
            
            if (searchType === 'all') {
                // For "all fields" search, we'll filter locally
                const filteredBooks = this.books.filter(book => 
                    book.title.toLowerCase().includes(query.toLowerCase()) ||
                    book.author.toLowerCase().includes(query.toLowerCase()) ||
                    (book.isbn && book.isbn.includes(query))
                );
                this.renderBooks(filteredBooks);
                return;
            } else {
                // Use specific API endpoints for targeted searches
                searchUrl = `${this.baseURL}/search/${searchType}?${searchType}=${encodeURIComponent(query)}`;
            }

            const response = await fetch(searchUrl);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const searchResults = await response.json();
            
            // Handle single book result from ISBN search
            const resultsArray = Array.isArray(searchResults) ? searchResults : [searchResults].filter(Boolean);
            
            this.renderBooks(resultsArray);
        } catch (error) {
            console.error('Error searching books:', error);
            this.showToast('error', 'Search failed', error.message);
        }
    }

    renderBooks(booksToRender = this.books) {
        const container = document.getElementById('booksContainer');
        const loading = document.getElementById('loading');
        
        if (loading) {
            loading.style.display = 'none';
        }

        if (booksToRender.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-book-open"></i>
                    <h3>No books found</h3>
                    <p>Start by adding your first book to the library</p>
                </div>
            `;
            return;
        }

        const viewClass = this.currentView === 'grid' ? 'books-grid' : 'books-list';
        container.innerHTML = `<div class="${viewClass}" id="booksList"></div>`;
        
        const booksList = document.getElementById('booksList');
        
        booksToRender.forEach(book => {
            const bookCard = this.createBookCard(book);
            booksList.appendChild(bookCard);
        });
    }

    createBookCard(book) {
        const card = document.createElement('div');
        card.className = `book-card ${this.currentView === 'list' ? 'list-view' : ''}`;
        
        const publishDate = book.publishDate ? new Date(book.publishDate).getFullYear() : 'Unknown';
        const pageCount = book.pageCount || 'Unknown';
        const isbn = book.isbn || 'Not specified';

        card.innerHTML = `
            <div class="book-card-header">
                <h3>${this.escapeHtml(book.title)}</h3>
                <p>by ${this.escapeHtml(book.author)}</p>
            </div>
            <div class="book-card-body">
                <div class="book-info">
                    <div class="book-info-item">
                        <i class="fas fa-barcode"></i>
                        <span>ISBN: ${isbn}</span>
                    </div>
                    <div class="book-info-item">
                        <i class="fas fa-calendar"></i>
                        <span>Published: ${publishDate}</span>
                    </div>
                    <div class="book-info-item">
                        <i class="fas fa-file-alt"></i>
                        <span>Pages: ${pageCount}</span>
                    </div>
                </div>
                <div class="book-actions">
                    <button class="btn btn-primary btn-small" onclick="libraryManager.editBook(${book.id})">
                        <i class="fas fa-edit"></i>
                        Edit
                    </button>
                    <button class="btn btn-danger btn-small" onclick="libraryManager.openDeleteModal(${book.id}, '${this.escapeHtml(book.title)}')">
                        <i class="fas fa-trash"></i>
                        Delete
                    </button>
                </div>
            </div>
        `;

        return card;
    }

    editBook(id) {
        const book = this.books.find(b => b.id === id);
        if (!book) return;

        this.currentEditId = id;
        document.getElementById('modalTitle').textContent = 'Edit Book';
        
        // Populate form with book data
        document.getElementById('title').value = book.title || '';
        document.getElementById('author').value = book.author || '';
        document.getElementById('isbn').value = book.isbn || '';
        document.getElementById('publishDate').value = book.publishDate || '';
        document.getElementById('pageCount').value = book.pageCount || '';

        this.openModal();
    }

    openDeleteModal(id, title) {
        this.currentDeleteId = id;
        document.getElementById('deleteBookTitle').textContent = title;
        document.getElementById('deleteModal').classList.add('show');
    }

    closeDeleteModal() {
        document.getElementById('deleteModal').classList.remove('show');
        this.currentDeleteId = null;
    }

    confirmDelete() {
        if (this.currentDeleteId) {
            this.deleteBook(this.currentDeleteId);
        }
    }

    openModal() {
        document.getElementById('bookModal').classList.add('show');
        document.getElementById('title').focus();
    }

    closeModal() {
        document.getElementById('bookModal').classList.remove('show');
        document.getElementById('bookForm').reset();
        document.getElementById('modalTitle').textContent = 'Add New Book';
        this.currentEditId = null;
    }

    toggleView(view) {
        this.currentView = view;
        
        // Update button states
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-view="${view}"]`).classList.add('active');
        
        // Re-render books with new view
        this.renderBooks();
    }

    updateStats() {
        const totalBooks = this.books.length;
        const authors = new Set(this.books.map(book => book.author)).size;
        const latestYear = this.books
            .filter(book => book.publishDate)
            .map(book => new Date(book.publishDate).getFullYear())
            .sort((a, b) => b - a)[0] || '-';

        document.getElementById('totalBooks').textContent = totalBooks;
        document.getElementById('totalAuthors').textContent = authors;
        document.getElementById('latestYear').textContent = latestYear;
    }

    showLoading(show) {
        const loading = document.getElementById('loading');
        if (loading) {
            loading.style.display = show ? 'flex' : 'none';
        }
    }

    showError(message) {
        const container = document.getElementById('booksContainer');
        container.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-exclamation-triangle" style="color: var(--danger-color);"></i>
                <h3>Error</h3>
                <p>${message}</p>
                <button class="btn btn-primary" onclick="libraryManager.loadBooks()">
                    <i class="fas fa-sync"></i>
                    Retry
                </button>
            </div>
        `;
    }

    showToast(type, title, message = '') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const iconMap = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle'
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

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the library manager when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.libraryManager = new LibraryManager();
});

// Handle service worker registration for PWA capabilities (optional)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        // Service worker registration would go here
    });
}