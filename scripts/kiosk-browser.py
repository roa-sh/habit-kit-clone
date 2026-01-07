#!/usr/bin/env python3
"""
Custom Kiosk Browser with Address Bar
Perfect for 320x480 portrait displays
F11 to toggle fullscreen
"""

import sys
from PyQt5.QtCore import Qt, QUrl, QSize
from PyQt5.QtWidgets import (QApplication, QMainWindow, QToolBar,
                             QLineEdit, QAction, QVBoxLayout, QWidget)
from PyQt5.QtWebEngineWidgets import QWebEngineView, QWebEngineSettings, QWebEngineProfile
from PyQt5.QtGui import QIcon

class KioskBrowser(QMainWindow):
    def __init__(self, url="http://localhost/"):
        super().__init__()

        # Window setup - 320x480 portrait
        self.setWindowTitle("Browser")
        self.setFixedSize(QSize(320, 480))

        # Track fullscreen state
        self.is_fullscreen = True

        # Create browser
        self.browser = QWebEngineView()

        # Browser settings
        settings = self.browser.settings()
        settings.setAttribute(QWebEngineSettings.JavascriptEnabled, True)
        settings.setAttribute(QWebEngineSettings.LocalStorageEnabled, True)
        settings.setAttribute(QWebEngineSettings.PluginsEnabled, True)

        # Mobile user agent
        profile = QWebEngineProfile.defaultProfile()
        profile.setHttpUserAgent(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) "
            "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 "
            "Mobile/15E148 Safari/604.1"
        )

        # Create navigation toolbar
        self.navbar = QToolBar()
        self.addToolBar(self.navbar)

        # Back button
        back_btn = QAction('◄', self)
        back_btn.setStatusTip('Back')
        back_btn.triggered.connect(self.browser.back)
        self.navbar.addAction(back_btn)

        # Forward button
        forward_btn = QAction('►', self)
        forward_btn.setStatusTip('Forward')
        forward_btn.triggered.connect(self.browser.forward)
        self.navbar.addAction(forward_btn)

        # Reload button
        reload_btn = QAction('⟳', self)
        reload_btn.setStatusTip('Reload')
        reload_btn.triggered.connect(self.browser.reload)
        self.navbar.addAction(reload_btn)

        # Home button
        home_btn = QAction('⌂', self)
        home_btn.setStatusTip('Home')
        home_btn.triggered.connect(self.navigate_home)
        self.navbar.addAction(home_btn)

        # Address bar (URL search bar)
        self.url_bar = QLineEdit()
        self.url_bar.returnPressed.connect(self.navigate_to_url)
        self.navbar.addWidget(self.url_bar)

        # Go button
        go_btn = QAction('Go', self)
        go_btn.setStatusTip('Go to URL')
        go_btn.triggered.connect(self.navigate_to_url)
        self.navbar.addAction(go_btn)

        # Update URL bar when page changes
        self.browser.urlChanged.connect(self.update_url_bar)

        # Set browser as central widget
        self.setCentralWidget(self.browser)

        # Load initial URL
        self.home_url = url
        self.browser.setUrl(QUrl(url))

        # Show window
        self.showFullScreen()

    def navigate_to_url(self):
        """Navigate to URL in address bar"""
        url = self.url_bar.text()

        # Add http:// if no protocol specified
        if not url.startswith('http://') and not url.startswith('https://'):
            url = 'http://' + url

        self.browser.setUrl(QUrl(url))

    def navigate_home(self):
        """Navigate to home URL"""
        self.browser.setUrl(QUrl(self.home_url))

    def update_url_bar(self, q):
        """Update address bar with current URL"""
        self.url_bar.setText(q.toString())
        self.url_bar.setCursorPosition(0)

    def toggle_fullscreen(self):
        """Toggle fullscreen mode with F11"""
        if self.is_fullscreen:
            # Exit fullscreen
            self.showNormal()
            self.navbar.show()
            self.setFixedSize(QSize(320, 480))
            self.is_fullscreen = False
        else:
            # Enter fullscreen
            self.setFixedSize(QSize(16777215, 16777215))  # Remove size constraint
            self.navbar.hide()
            self.showFullScreen()
            self.is_fullscreen = True

    def keyPressEvent(self, event):
        # F11 to toggle fullscreen
        if event.key() == Qt.Key_F11:
            self.toggle_fullscreen()
        # Ctrl+Q to quit
        elif event.key() == Qt.Key_Q and event.modifiers() == Qt.ControlModifier:
            self.close()
        # F5 to reload
        elif event.key() == Qt.Key_F5:
            self.browser.reload()
        # Escape to exit fullscreen
        elif event.key() == Qt.Key_Escape and self.is_fullscreen:
            self.toggle_fullscreen()

if __name__ == '__main__':
    url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost/"
    app = QApplication(sys.argv)
    browser = KioskBrowser(url)
    sys.exit(app.exec_())
