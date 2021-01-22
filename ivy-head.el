(setq-default wr--head-var-a "headline name")

(defun wr/counsel-outline-action (x)
  (setq wr--head-var-a (car x)))

(defun wr/counsel-outline ()
  (interactive)
  (let ((settings (cdr (assq major-mode counsel-outline-settings))))
    (ivy-read "Outline: " (counsel-outline-candidates settings)
              :action (or (plist-get settings :action)
                          #'wr/counsel-outline-action)
              :history (or (plist-get settings :history)
                           'counsel-outline-history)
              :preselect (max (1- counsel-outline--preselect) 0)
              :caller (or (plist-get settings :caller)
                          'wr/counsel-outline))))

(defun wr/insert-a-head-from-a-file (x)
  (interactive)
  (xref-push-marker-stack)
  (save-restriction
    (save-excursion
      (with-ivy-window
        (pcase (cdr x)
          (`(:path ,foo :title ,bar) (progn
                                       (with-temp-buffer
                                         (erase-buffer)
                                         (insert-file-contents foo)
                                         (call-interactively #'wr/counsel-outline))
                                       (insert (format "[[file:%s::*%s][%s]]" foo (car (last (split-string (substring-no-properties wr--head-var-a) " → ")))
                                                       (string-trim-left (car (last (split-string (substring-no-properties wr--head-var-a) " → "))))))))))
      (message "A head has been inserted.")
      (xref-goto-xref))))


(ivy-set-actions
 t
 '(("h" wr/insert-a-head-from-a-file "insert")))
