;;; ox-kishvanchee.el --- LaTeX Jake's Resume Backend for Org Export Engine -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Kishore Vancheeshwaran
;;
;; Author: Kishore Vancheeshwaran <v.kish.vanchee@gmail.com>
;; Maintainer: Kishore Vancheeshwaran <v.kish.vanchee@gmail.com>
;; Created: July 19, 2022
;; Modified: July 19, 2022
;; Version: 0.0.1
;; Keywords: tex
;; Homepage: https://github.com/kishore/orgmode-resume
;; Package-Requires: ((emacs "28.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;; My custom export following jake's resume format
;;
;;
;;; Code:

(require 'ox-latex)
(require 'org)

(defun ox-kishvanchee--org-timestamp-to-shortdate (date_str)
"Format orgmode timestamp DATE_STR  into a short form date.
Other strings are just returned unmodified

e.g. <2002-08-12 Mon> => Aug 2012
today => today"
  (if (string-match (org-re-timestamp 'active) date_str)
      (let* ((abbreviate 't)
             (dte (org-parse-time-string date_str))
             (month (nth 4 dte))
             (year (nth 5 dte))) ;;'(02 07 2015)))
        (concat
         (calendar-month-name month abbreviate) " " (number-to-string year)))
    date_str))

(defun ox-kishvanchee--format-time-window (from-date to-date)
"Join date strings in a time window.
FROM-DATE -- TO-DATE
in case TO-DATE is nil return Present"
  (concat
   (ox-kishvanchee--org-timestamp-to-shortdate from-date)
   " -- "
   (if (= (length to-date) 0) "Present"
     (ox-kishvanchee--org-timestamp-to-shortdate to-date))))


;;; Define Back-End
(org-export-define-derived-backend 'kishvanchee 'latex
  ;'((section . org-kishvanchee-latex-section))
  :options-alist
  '((:mobile "MOBILE" nil nil parse)
    (:linkedin "LINKEDIN" nil nil parse)
    (:anon "ANON" nil nil parse))
  :translate-alist '((template . org-kishvanchee-template)
                     (headline . org-kishvanchee-headline)))

(defun org-kishvanchee-template (contents info)
  "Return complete document string after LaTeX conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
   (setq anon (org-export-data (plist-get info :anon) info))
  (concat
   "\\input{template.tex}\n\n"

   ;; Creator
   (and (plist-get info :with-creator)
        (concat "\\creator{" (plist-get info :creator) "}" "\n\n"))


   ;; Document start.
   "\\begin{document}\n\n"

   (format "\\begin{center}\n")
   ;; name
   (let ((name (if (org-string-nw-p anon)
                     "Firstname lastname"
                     (and (plist-get info :with-author)
                        (let ((auth (plist-get info :author)))
                          (and auth (org-export-data auth info)))))))
     (format "{\\Huge \\scshape \\color{TextColor} %s } \\\\ \\vspace{1pt}\n" name))
   ;; mobile
   (let ((mobile (if (org-string-nw-p anon)
                     "+00 98765 43210"
                   (org-export-data (plist-get info :mobile) info))))
     (when (org-string-nw-p mobile)
      (format "\\small %s $|$" mobile)))
   ;; email
   (let ((email (if (org-string-nw-p anon)
                     "firstname.lastname@gmail.com"
                     (and (plist-get info :with-email)
                          (org-export-data (plist-get info :email) info)))))
     (format " \\href{mailto:%s}{%s} " email email))
   ;; linkedin
   (let ((linkedin (if (org-string-nw-p anon)
                     "anon"
                   (org-export-data (plist-get info :linkedin) info))))
     (when (org-string-nw-p linkedin)
       (format "$|$ \\href{https://linkedin.com/in/%s/}{linkedin.com/in/%s/}" linkedin linkedin)))
   (format "\n\\end{center}\n\n")

   contents

   ;; Document end.
   "\n\n\\end{document}"))

(defun org-kishvanchee--format-cventry (headline contents info)
  "Format HEADLINE as as cventry.
CONTENTS holds the contents of the headline.  INFO is a plist used
as a communication channel."
  (let ((level (org-export-get-relative-level headline info)))
   (cond ((= level 1)
          (let* ((title (org-export-data (org-element-property :title headline) info)))
            (format "\\section{%s}\n%s" title contents)))
         ((= level 2)
          (let* ((title (org-export-data (org-element-property :title headline) info))
                 (loc (org-export-data (org-element-property :LOCATION headline) info)))
            (format "\\resumeSubheading{%s}{%s}\n%s\n" title loc contents)))
         ((= level 3)
          (let* ((title (org-export-data (org-element-property :title headline) info))
                 (from (org-export-data (org-element-property :FROM headline) info))
                 (to (org-export-data (org-element-property :TO headline) info))
                 (period (ox-kishvanchee--format-time-window from to)))
            (format "\\resumeSubSubheading{%s}{%s}\n%s\n" title period contents))))))


(defun org-kishvanchee-headline (headline contents info)
  "Transcode HEADLINE into ox-kishvanchee format.
CONTENTS is contents of the headline. INFO is plist used."
  (unless (org-element-property :footnote-section-p headline)
    (org-kishvanchee--format-cventry headline contents info)))

(provide 'ox-kishvanchee)
;;; ox-kishvanchee.el ends here
