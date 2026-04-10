;;; package --- Summary  -*- lexical-binding: t; -*-

;;; Commentary:

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




;; Vertico & assocated packages ------------------------------------------

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

(use-package corfu
  :straight t
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  :init

  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)

  ;; Enable optional extension modes:
  ;; (corfu-history-mode)
  ;; (corfu-popupinfo-mode)
  )

;; Add extensions
(use-package cape
  :straight t
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c p ? to for help.
  :bind ("C-c p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  ;; Alternatively bind Cape commands individually.
  ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
  ;;        ...)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  ;; (add-hook 'completion-at-point-functions #'cape-history)
  ;; ...
)

;; Use Dabbrev with Corfu!
(use-package dabbrev
  :straight t
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'authinfo-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

;; A few more useful configurations...
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
   '(read-only t cursor-intangible t face minibuffer-prompt))
  
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)
  
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  
  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)
  
  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))


(use-package consult
  :straight t
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command) ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer) ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame) ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)	;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)		;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer) ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store) ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop) ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flymake) ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)	 ;; orig. goto-line
         ("M-g M-g" . consult-goto-line) ;; orig. goto-line
         ("M-g o" . consult-outline) ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find) ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history) ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history) ;; orig. isearch-edit-string
         ("M-s l" . consult-line) ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)	;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history) ;; orig. next-matching-history-element
         ("M-r" . consult-history)) ;; orig. previous-matching-history-element

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

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
  :straight t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(setenv "GIT_ASKPASS" "git-gui--askpass")

;; projectile ----------------------------------------------------------

(use-package projectile
  :straight t
  :diminish projectile
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired))


;; lsp-mode ------------------------------------------------------------

(defun pl/lsp-mode-setup ()
    (setq pl/lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))


(use-package lsp-mode
  :straight t
  :custom
  (lsp-completion-provider :none) ;; we use Corfu!
  :init
  (setq lsp-keymap-prefix "C-c l")

  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(flex))) ;; Configure flex  
  :hook
  ((lsp-mode . pl/lsp-mode-setup)
   (lsp-completion-mode . my/lsp-mode-setup-completion)
   (c++-mode . lsp)
   (c-mode . lsp)
   (nix-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred))


(defun pl/when-linux-install ()
  (cond
   ((eq system-type 'gnu/linux)
    ;; nix-mode ------------------------------------------------------------

    (use-package nix-mode
      :straight t
      :mode "\\.nix\\'")
    
    (use-package dap-mode
      :straight t
      :config

      (require 'dap-cpptools)

      (require 'dap-gdb)
      (setq dap-gdb-debug-program '("gdb" "-i" "dap"))
      ;;
      ;; (dap-register-debug-template
      ;;  "GDB::Run"
      ;;  (list :type "gdb"
      ;;        :request "launch"
      ;;        :name "GDB::Run"
      ;;        :target nil
      ;; 	 :program "/home/peter/tmp/a.out"
      ;;        :cwd "/home/peter/tmp/"
      ;; 	 ))
      
      (require 'dap-lldb)
      (setq dap-lldb-debug-program '("lldb-dap"))
      ;; (dap-register-debug-template
      ;;  "LLDB::Run"
      ;;  (list :type "lldb-vscode"
      ;;        :cwd "/home/peter/tmp/"
      ;;        :request "launch"
      ;;        :program "/home/peter/tmp/a.out"
      ;;        :name "LLDB::Run"))
      
      )
    )))

(pl/when-linux-install)

(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode)

(use-package consult-lsp
  :straight t)

(use-package flycheck
  :straight t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; org-mode --------------------------------------------------

;; Org Mode Configuration ------------------------------------------------------

(defun pl/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun pl/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))


(use-package org
  :straight t
  :hook (org-mode . pl/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (pl/org-font-setup))

(use-package org-bullets
  :straight t
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun pl/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :straight t
  :hook (org-mode . pl/org-mode-visual-fill))

;; org-store-link, org-agenda, and org-capture should be
;; reachable from anywhere
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)


;; cmake-mode ------------------------------------------------

(use-package cmake-mode
  :straight t
  :hook
  ((cmake-mode . lsp)))

;; rustic ----------------------------------------------------

(use-package rust-mode
  :straight t
  :init
  (setq rust-mode-treesitter-derive t))

(use-package rustic
  :straight t
  :after (rust-mode)
  :custom
  (rustic-analyzer-command '("rustup" "run" "stable" "rust-analyzer")))

;;; init.el ends here
