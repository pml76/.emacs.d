
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
	"straight/repos/straight.el/bootstrap.el"
	(or (bound-and-true-p straight-base-dir)
	    user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://radian-software.github.io/straight.el/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)



(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)          ; Disable the menu bar



(defvar pl/default-font-size 140)
(defvar pl/default-font "JetBrains Mono")
(defvar pl/variable-pitch-font "Source Serif 4")
(defvar pl/variable-pitch-font-size 140)
(defvar pl/fixed-pitch-font "JetBrains Mono")
(defvar pl/fixed-pitch-font-size 140)

(message "Setting faces!")

(when (member pl/default-font (font-family-list))
  (set-face-attribute 'default nil
		      :font pl/default-font
		      :height pl/default-font-size))

(use-package mixed-pitch
  :straight t
  :config
  (when (member pl/variable-pitch-font (font-family-list))
    (set-face-attribute 'variable-pitch nil
			:family pl/variable-pitch-font
			:height pl/variable-pitch-font-size)))

(when (member pl/fixed-pitch-font (font-family-list))
  (set-face-attribute 'fixed-pitch nil
		      :font pl/fixed-pitch-font
		      :height pl/fixed-pitch-font-size))



(defun pl/set-transparency ()
"Set the transparency according to the platform."
(cond
 ((eq system-type 'windows-nt)
  (set-frame-parameter (selected-frame) 'alpha '(95 . 100))
  (add-to-list 'default-frame-alist '(alpha . (95 . 100)))
  (message "Running on Windows"))
 ((eq system-type 'gnu/linux)
  (set-frame-parameter nil 'alpha-background 95)
  (add-to-list 'default-frame-alist '(alpha-background . 95))
  (message "Running on GNU/Linux"))
 (t
  (message "Unknown operating system"))))



(defun pl/setup-gui ()
  "Setup the gui."
  (pl/set-transparency))

(if (daemonp)
    (add-hook 'after-make-frame-functions
	      (lambda (frame)
		;; (setq doom-modeline-icon t)
		(with-selected-frame frame
		  (pl/setup-gui)
		  )))
  (pl/setup-gui))

