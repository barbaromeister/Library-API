// Library Management System JavaScript

class LibraryManager {
    constructor() {
        this.books = [];
        this.currentView = 'grid';
        this.currentEditId = null;
        this.baseURL = '/api/books';
        this.authURL = '/api/auth';
        this.currentUser = null;
        this.init();
    }

    init() {
        this.bindEvents();
        this.checkAuthStatus();
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
                this.closeAuthModals();
            }
        });

        // Authentication event handlers
        document.getElementById('loginBtn').addEventListener('click', () => {
            this.openLoginModal();
        });

        document.getElementById('registerBtn').addEventListener('click', () => {
            this.openRegisterModal();
        });

        document.getElementById('logoutBtn').addEventListener('click', () => {
            this.logout();
        });

        // Auth modal close buttons
        document.getElementById('closeLoginModal').addEventListener('click', () => {
            this.closeLoginModal();
        });

        document.getElementById('cancelLoginBtn').addEventListener('click', () => {
            this.closeLoginModal();
        });

        document.getElementById('closeRegisterModal').addEventListener('click', () => {
            this.closeRegisterModal();
        });

        document.getElementById('cancelRegisterBtn').addEventListener('click', () => {
            this.closeRegisterModal();
        });

        // Auth form submissions
        document.getElementById('loginForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        document.getElementById('registerForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleRegister();
        });

        // Navigation button to search section
        document.getElementById('goToSearchBtn').addEventListener('click', () => {
            this.scrollToBookSearch();
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

    // Authentication methods
    async checkAuthStatus() {
        try {
            const response = await fetch(`${this.authURL}/me`, {
                credentials: 'include'
            });
            
            if (response.ok) {
                const data = await response.json();
                if (data.success) {
                    this.currentUser = {
                        username: data.username,
                        role: data.role
                    };
                    this.showAuthenticatedUI();
                    this.loadBooks();
                    this.updateStats();
                } else {
                    this.showUnauthenticatedUI();
                }
            } else {
                this.showUnauthenticatedUI();
            }
        } catch (error) {
            console.error('Auth check failed:', error);
            this.showUnauthenticatedUI();
        }
    }

    showAuthenticatedUI() {
        document.getElementById('authButtons').style.display = 'none';
        document.getElementById('userInfo').style.display = 'flex';
        document.getElementById('welcomeText').textContent = `Welcome, ${this.currentUser.username}`;
        
        document.getElementById('bookSearchSection').style.display = 'block';
        document.getElementById('contentControls').style.display = 'block';
        document.getElementById('searchSection').style.display = 'block';
        document.getElementById('statsSection').style.display = 'block';
        document.getElementById('booksSection').style.display = 'block';
        
        this.initBookSearch();
    }

    showUnauthenticatedUI() {
        document.getElementById('authButtons').style.display = 'flex';
        document.getElementById('userInfo').style.display = 'none';
        
        document.getElementById('bookSearchSection').style.display = 'none';
        document.getElementById('contentControls').style.display = 'none';
        document.getElementById('searchSection').style.display = 'none';
        document.getElementById('statsSection').style.display = 'none';
        document.getElementById('booksSection').style.display = 'none';
    }

    openLoginModal() {
        document.getElementById('loginModal').style.display = 'flex';
        document.getElementById('loginUsername').focus();
    }

    closeLoginModal() {
        document.getElementById('loginModal').style.display = 'none';
        document.getElementById('loginForm').reset();
    }

    openRegisterModal() {
        document.getElementById('registerModal').style.display = 'flex';
        document.getElementById('registerUsername').focus();
    }

    closeRegisterModal() {
        document.getElementById('registerModal').style.display = 'none';
        document.getElementById('registerForm').reset();
    }

    closeAuthModals() {
        this.closeLoginModal();
        this.closeRegisterModal();
    }

    async handleLogin() {
        const form = document.getElementById('loginForm');
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
                this.currentUser = {
                    username: data.username,
                    role: data.role
                };
                this.closeLoginModal();
                this.showAuthenticatedUI();
                this.loadBooks();
                this.updateStats();
                this.showToast('success', 'Login successful', `Welcome back, ${data.username}!`);
            } else {
                this.showToast('error', 'Login failed', data.message);
            }
        } catch (error) {
            console.error('Login error:', error);
            this.showToast('error', 'Login failed', 'Network error occurred');
        }
    }

    async handleRegister() {
        const form = document.getElementById('registerForm');
        const formData = new FormData(form);
        
        const password = formData.get('password');
        const confirmPassword = formData.get('confirmPassword');
        
        if (password !== confirmPassword) {
            this.showToast('error', 'Registration failed', 'Passwords do not match');
            return;
        }
        
        try {
            const response = await fetch(`${this.authURL}/register`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    username: formData.get('username'),
                    email: formData.get('email'),
                    password: password
                })
            });
            
            const data = await response.json();
            
            if (data.success) {
                this.closeRegisterModal();
                this.showToast('success', 'Registration successful', 'Please login with your new account');
                this.openLoginModal();
            } else {
                this.showToast('error', 'Registration failed', data.message);
            }
        } catch (error) {
            console.error('Registration error:', error);
            this.showToast('error', 'Registration failed', 'Network error occurred');
        }
    }

    async logout() {
        try {
            const response = await fetch(`${this.authURL}/logout`, {
                method: 'POST',
                credentials: 'include'
            });
            
            const data = await response.json();
            
            if (data.success) {
                this.currentUser = null;
                this.showUnauthenticatedUI();
                this.showToast('success', 'Logout successful', 'See you next time!');
            }
        } catch (error) {
            console.error('Logout error:', error);
            this.currentUser = null;
            this.showUnauthenticatedUI();
        }
    }

    // Book Search Methods
    initBookSearch() {
        const searchInput = document.getElementById('bookSearchInput');
        const suggestionsContainer = document.getElementById('searchSuggestions');
        const searchResults = document.getElementById('searchResults');
        const searchLoading = document.getElementById('searchLoading');
        let searchTimeout;

        // Handle search input
        searchInput.addEventListener('input', (e) => {
            const query = e.target.value.trim();
            
            clearTimeout(searchTimeout);
            
            if (query.length < 3) {
                suggestionsContainer.style.display = 'none';
                searchResults.innerHTML = '';
                return;
            }
            
            searchTimeout = setTimeout(() => {
                this.searchBooks(query, true);
            }, 300);
        });

        // Handle enter key for full search
        searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                const query = e.target.value.trim();
                if (query.length >= 3) {
                    suggestionsContainer.style.display = 'none';
                    this.searchBooks(query, false);
                }
            }
        });

        // Hide suggestions when clicking outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.book-search-container')) {
                suggestionsContainer.style.display = 'none';
            }
        });
    }

    async searchBooks(query, showSuggestions = false) {
        const searchLoading = document.getElementById('searchLoading');
        const suggestionsContainer = document.getElementById('searchSuggestions');
        const searchResults = document.getElementById('searchResults');

        try {
            searchLoading.style.display = 'block';
            
            const endpoint = showSuggestions ? 'suggest' : 'search';
            const limit = showSuggestions ? 5 : 12;
            
            const response = await fetch(`/api/books/${endpoint}?query=${encodeURIComponent(query)}&${showSuggestions ? 'limit' : 'maxResults'}=${limit}`, {
                credentials: 'include'
            });

            if (response.ok) {
                if (showSuggestions) {
                    const suggestions = await response.json();
                    this.renderSuggestions(suggestions);
                } else {
                    const data = await response.json();
                    this.renderSearchResults(data.suggestions || data);
                }
            } else {
                throw new Error('Search failed');
            }

        } catch (error) {
            console.error('Search error:', error);
            if (showSuggestions) {
                suggestionsContainer.style.display = 'none';
            } else {
                searchResults.innerHTML = this.createNoResultsHTML('Search failed. Please try again.');
            }
        } finally {
            searchLoading.style.display = 'none';
        }
    }

    renderSuggestions(suggestions) {
        const container = document.getElementById('searchSuggestions');
        
        if (!suggestions || suggestions.length === 0) {
            container.style.display = 'none';
            return;
        }

        container.innerHTML = suggestions.map(book => `
            <div class="suggestion-item" onclick="libraryManager.selectSuggestion('${this.escapeHtml(JSON.stringify(book).replace(/'/g, "\\'"))}')">
                <img class="suggestion-cover" 
                     src="${book.thumbnail || book.smallThumbnail || '/api/placeholder/50x75'}" 
                     alt="${this.escapeHtml(book.title)}"
                     onerror="this.src='/api/placeholder/50x75'">
                <div class="suggestion-info">
                    <div class="suggestion-title">${this.escapeHtml(book.title)}</div>
                    ${book.authors ? `<div class="suggestion-author">${this.escapeHtml(book.authors)}</div>` : ''}
                    ${book.publisher ? `<div class="suggestion-publisher">${this.escapeHtml(book.publisher)}</div>` : ''}
                </div>
            </div>
        `).join('');
        
        container.style.display = 'block';
    }

    selectSuggestion(bookDataStr) {
        try {
            const book = JSON.parse(bookDataStr);
            document.getElementById('bookSearchInput').value = book.title;
            document.getElementById('searchSuggestions').style.display = 'none';
            this.renderSearchResults([book]);
        } catch (error) {
            console.error('Error selecting suggestion:', error);
        }
    }

    renderSearchResults(books) {
        const container = document.getElementById('searchResults');
        
        if (!books || books.length === 0) {
            container.innerHTML = this.createNoResultsHTML('No books found. Try a different search term.');
            return;
        }

        container.innerHTML = books.map(book => this.createBookCard(book)).join('');
        
        // Add event listeners to the "Add to Library" buttons
        container.querySelectorAll('.add-to-library-btn').forEach(button => {
            button.addEventListener('click', (e) => {
                e.preventDefault();
                const bookData = JSON.parse(button.getAttribute('data-book'));
                this.addToLibrary(bookData, button);
            });
        });
    }

    createBookCard(book) {
        const coverUrl = book.mediumImage || book.thumbnail || book.smallThumbnail || '/api/placeholder/120x180';
        const title = this.escapeHtml(book.title || 'Unknown Title');
        const authors = this.escapeHtml(book.authors || 'Unknown Author');
        const publisher = book.publisher ? this.escapeHtml(book.publisher) : '';
        const publishedDate = book.publishedDate ? ` (${book.publishedDate.substring(0, 4)})` : '';
        const bookId = 'book_' + Math.random().toString(36).substr(2, 9);

        return `
            <div class="book-result-card">
                <div class="book-cover-container">
                    <img class="book-cover" 
                         src="${coverUrl}" 
                         alt="${title}"
                         onerror="this.src='/api/placeholder/120x180'">
                </div>
                <div class="book-info">
                    <div class="book-title">${title}</div>
                    <div class="book-author">${authors}</div>
                    ${publisher ? `<div class="book-publisher">${publisher}${publishedDate}</div>` : ''}
                </div>
                <button class="add-to-library-btn" id="${bookId}" data-book='${this.escapeHtml(JSON.stringify(book))}'>
                    <i class="fas fa-plus"></i>
                    Add to Library
                </button>
            </div>
        `;
    }

    createNoResultsHTML(message) {
        return `
            <div class="no-results">
                <i class="fas fa-search"></i>
                <h3>No Results</h3>
                <p>${message}</p>
            </div>
        `;
    }

    async addToLibrary(bookData, buttonElement = null) {
        try {
            // Accept book data directly or parse if it's a string
            const book = typeof bookData === 'string' ? JSON.parse(bookData) : bookData;
            
            // Use the passed button element or try to find it from event
            const clickedButton = buttonElement || event?.target?.closest?.('.add-to-library-btn');
            if (clickedButton) {
                clickedButton.disabled = true;
                clickedButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
            }
            
            // Call the API to add book to collection
            const response = await fetch('/api/books/add-to-collection', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                credentials: 'include',
                body: JSON.stringify(book)
            });
            
            const data = await response.json();
            
            if (data.success) {
                this.showToast('success', 'Book Added', `"${book.title}" added to your library!`);
                
                if (clickedButton) {
                    clickedButton.innerHTML = '<i class="fas fa-check"></i> Added';
                    clickedButton.classList.add('added');
                }
                
            } else {
                throw new Error(data.message || 'Failed to add book');
            }
            
        } catch (error) {
            console.error('Error adding book to library:', error);
            this.showToast('error', 'Error', 'Failed to add book to library: ' + error.message);
            
            // Re-enable the button on error
            const errorButton = buttonElement || event?.target?.closest?.('.add-to-library-btn');
            if (errorButton) {
                errorButton.disabled = false;
                errorButton.innerHTML = '<i class="fas fa-plus"></i> Add to Library';
            }
        }
    }

    scrollToBookSearch() {
        const bookSearchSection = document.getElementById('bookSearchSection');
        if (bookSearchSection) {
            bookSearchSection.scrollIntoView({ 
                behavior: 'smooth',
                block: 'start'
            });
            // Focus on the search input
            setTimeout(() => {
                const searchInput = document.getElementById('bookSearchInput');
                if (searchInput) {
                    searchInput.focus();
                }
            }, 500);
        }
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