;; Package Manager Setup -------------------------------------------------------

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

;; Basic UI Configuration ------------------------------------------------------

(defvar runemacs/default-font-size 180)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)          ; Disable the menu bar


;; Font Configuration ----------------------------------------------------------

(defun pl/set-font-faces ()
  (message "Setting faces!")
  ;(set-face-attribute 'default nil :font "JetBrains Mono" :weight 'light :height 180)
  ;(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :weight 'light :height 190)
  ;(set-face-attribute 'variable-pitch nil :font "Iosevka Aile" :weight 'light :height 1.3)
  (set-face-attribute 'default nil :font "Fira Code" :height runemacs/default-font-size)

  ;; Set the fixed pitch face
  (set-face-attribute 'fixed-pitch nil :font "Fira Code" :height 260)
  
  ;; Set the variable pitch face
  (set-face-attribute 'variable-pitch nil :font "Cantarell" :height 295 :weight 'regular))

(defun pl/set-transparency ()
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
  (pl/set-font-faces)
  (pl/set-transparency))

(if (daemonp)
    (add-hook 'after-make-frame-functions
	      (lambda (frame)
		;; (setq doom-modeline-icon t)
		(with-selected-frame frame
		  (pl/setup-gui)
		  )))
  (pl/setup-gui))


;; Advanced UI Configuration --------------------------------------------------

(use-package all-the-icons
  :straight t
  :if (display-graphic-p))

(use-package nerd-icons
  :straight t)

(use-package doom-modeline
  :straight t
  :after all-the-icons nerd-icons
  :init (doom-modeline-mode 1))

(use-package doom-themes
  :straight t
  :custom
  (doom-themes-enabe bold t)    ; if nil, bold is universally disabled
  (doom-themes enable-italic t) ; if nil, italics are universally disabled

  ;; use "doom-atom" for less minimal icon theme
  (doom-themes-treemacs-theme "doom-atom")

  :config
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  
  ;; Enable custom neotree theme (nerd-icons must be installed)
  (doom-themes-neotree-config)
  
  ;; Corrects (and improves) org-mode's native fontification
  (doom-themes-org-config))



;; Utilities -------------------------------------------------------------------

(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))


(use-package paredit
  :straight t)

(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)



(use-package which-key
  :straight t
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package helpful
  :straight t
  :bind
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))




;;; Completion

(use-package vertico
  :straight t
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 20)
  (vertico-resize t)
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package savehist
  :straight t
  :init
  (savehist-mode))

(use-package emacs
  :straight t
  :custom
  ;; Enable context menu. `vertico-multiform-mode´ adds a menu in the minibuf
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide command in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers. This setting is useful
  ;; beyond Vertico
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

(use-package marginalia
  :straight t
  ;; Bind `marginalia-cycle´ locally in the minibuffer. To make the binding
  ;; availabl in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map`.
  :bind (:map minibuffer-local-map
	      ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such
  ;; that the mode gets enabled right away. Note that this forces loading
  ;; the package.
  (marginalia-mode))

(use-package orderless
  :straight t
  :custom
  ;; Configure custom stype dispatcher (see the Consult wiki)
  ;; (orderless-stype-dispatchers
  ;;    '(+orderless-consult-dispatch orderless-affix-dispatch))
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))


(use-package nerd-icons-completion
  :straight t
  :after nerd-icons
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; Treemacs --------------------------------------------------------------------

(use-package treemacs
  :straight t
;  :init
;  (with-eval-after-load 'winum
;    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-buffer-name-function            #'treemacs-default-buffer-name
          treemacs-buffer-name-prefix              " *Treemacs-Buffer-"
          treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-hide-dot-jj-directory           t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-files-by-mouse-dragging    t
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :straight t
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :straight t
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :straight t
  :after (treemacs magit))

;(use-package treemacs-perspective ;;treemacs-perspective if you use perspective.el vs. persp-mode
;  :straight t
;  :after (treemacs perspective) ;;or perspective vs. persp-mode
;  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :straight t
  :after (treemacs)
  :config (treemacs-set-scope-type 'Tabs))

(treemacs-start-on-boot)


;; perspective ---------------------------------------------------------

;(use-package perspective
;  :straight t)

;; magit ---------------------------------------------------------------

(use-package magit
  :straight t)

;; projectile ----------------------------------------------------------

(use-package projectile
  :straight t)

;; nix-mode ------------------------------------------------------------

(use-package nix-mode
  :straight t
  :mode "\\.nix\\'")


;; lsp-mode ------------------------------------------------------------

(use-package lsp-mode
  :straight t
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((c++-mode . lsp)
	 (nix-mode . lsp)
	 (lsp-mode . lsp-enable-which-key-integration)) 
  :commands lsp)

(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode)

(use-package dap-mode
  :straight t)
