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

;; Font Configuration ----------------------------------------------------------

(set-face-attribute 'default nil :font "Fira Code" :height runemacs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code" :height 260)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 295 :weight 'regular)


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




(use-package all-the-icons-completion
  :straight t
  :after all-the-icons
  :init
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
  (all-the-icons-completion-mode))
