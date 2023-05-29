;Basic things
(setq display-line-numbers-type 'relative) 
(global-display-line-numbers-mode) 
(menu-bar-mode -1)
(tool-bar-mode -1)
(set-face-attribute 'default nil :font "Noto Sans Mono SemiBold" :height 115)
(scroll-bar-mode -1)
(setq ring-bell-function 'ignore)
(setq make-backup-files nil)
(setq auto-save-default nil)

;Package Repos
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(use-package doom-themes
:ensure t
:config
(load-theme 'doom-gruvbox t))

;; Enable Evil
(use-package evil
  :ensure t
  :config
(evil-mode 1))
(evil-set-undo-system 'undo-redo)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" default))
 '(package-selected-packages '(doom-themes use-package evil-tutor evil-collection)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
