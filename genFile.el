
(defvar cwd default-directory)
(defvar workdir "./")
(eval-buffer)
(add-to-list 'load-path cwd)
(require 'ox-kishvanchee)

(defun export-latex (backend file)
  "Exporting to latex pdf"
  (let ((workfile (concat workdir file))
        (outfile (concat workdir (file-name-sans-extension file) ".tex")))
    (message (format "%s exists: %s" workfile (file-exists-p workfile)))
    (find-file workfile)
    (org-mode)
    (org-export-to-file backend outfile)
    (shell-command (format "pdflatex %s" outfile) "*Messages*" "*Messages*")
    ))


(export-latex 'kishvanchee "myresume.org")
