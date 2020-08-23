;;; header-info.el --- Display buffer information in the header line

;; Copyright (C) 2020 Ferdinand Pieper

;; Author: Ferdinand Pieper <mail@pie.tf>
;; Created: 23 Aug 2020
;; URL: https://github.com/fpiper/header-info

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Minor mode to display part of the mode line in the header line
;; instead. Customize `header-info-header-line-format' and
;; `header-info-mode-line-format' to determine what to show in the
;; header and mode line when turned on.
;;
;;; Code:

(defvar header-info-old-header-line nil)
(defvar header-info-old-mode-line nil)
(make-local-variable 'header-info-old-header-line)
(make-local-variable 'header-info-old-mode-line)

(defvar mode-line-major-mode
  (list `(:propertize ("" mode-name)
		      help-echo "Major mode\n\
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes"
		      mouse-face mode-line-highlight
		      local-map ,mode-line-major-mode-keymap)
	'("" mode-line-process))
  "Mode line construct for displaying major and minor modes.")
(defvar mode-line-minor-modes
  (let ((recursive-edit-help-echo "Recursive edit, type C-M-c to get out"))
    (list (propertize "%[" 'help-echo recursive-edit-help-echo)
	  "("
	  `(:propertize ("" minor-mode-alist)
			mouse-face mode-line-highlight
			help-echo "Minor mode\n\
mouse-1: Display minor mode menu\n\
mouse-2: Show help for minor mode\n\
mouse-3: Toggle minor modes"
			local-map ,mode-line-minor-mode-keymap)
	  (propertize "%n" 'help-echo "mouse-2: Remove narrowing from buffer"
		      'mouse-face 'mode-line-highlight
		      'local-map (make-mode-line-mouse-map
				  'mouse-2 #'mode-line-widen))
	  " )"
	  (propertize "%]" 'help-echo recursive-edit-help-echo)
	  " "))
  "Mode line construct for displaying minor modes.")

(defgroup header-info nil
  "Display information in the header line."
  :group 'tools)

(defcustom header-info-header-line-format
  (list "  "
        '(:eval (let ((name (buffer-name)))
                  (cond ((not buffer-file-truename)
                         ;; (propertize name 'face 'bold)
                         mode-line-buffer-identification
                         )
                        ((equal name (file-name-nondirectory buffer-file-truename))
                         (concat
                          ;; (propertize (f-filename buffer-file-truename) 'face 'bold)
                          (format-mode-line mode-line-buffer-identification)
                          " "
                          (f-dirname buffer-file-truename)
                          "/…" ))
                        (t
                         (concat (propertize name 'face 'bold)
                                 " "
                                 buffer-file-truename)))))

        ;; Right aligned
        '(:eval (let* ((right-text (format-mode-line mode-line-major-mode)))
                  (concat (propertize
                           " " 'display
                           `((space :align-to (- (+ right right-fringe right-margin)
                                                 ,(+ 3 (string-width right-text))))))
                          right-text))))
  "`header-line-format' to use in `header-info-mode'."
  :group 'header-info
  :type '(list))

(defcustom header-info-mode-line-format
  `("%e"
    (:eval (window-numbering-get-number-string))
    mode-line-front-space
    mode-line-mule-info
    mode-line-client
    mode-line-modified
    mode-line-remote
    mode-line-frame-identification
    ;; mode-line-buffer-identification
    "   "
    mode-line-position
    (vc-mode vc-mode)
    "  "
    ,mode-line-minor-modes
    ;; mode-line-modes
    mode-line-misc-info
    mode-line-end-spaces
    )
  "`mode-line-format' to use in `header-info-mode'."
  :group 'header-info
  :type '(list))

(defun turn-on-header-info-mode ()
  (setq header-info-old-header-line header-line-format
        header-line-format          header-info-header-line-format)
  (setq header-info-old-mode-line   mode-line-format
        mode-line-format            header-info-mode-line-format))
(defun turn-off-header-info-mode ()
  (setq header-line-format header-info-old-header-line)
  (setq mode-line-format   header-info-old-mode-line))

(define-minor-mode header-info-mode
  "Minor mode to show file information in the header line."
  nil
  nil
  nil
  (if header-info-mode
      (turn-on-header-info-mode)
    (turn-off-header-info-mode)))

(define-globalized-minor-mode global-header-info-mode
  header-info-mode turn-on-header-info-mode)


(provide 'header-info)
;;; header-info.el ends here
