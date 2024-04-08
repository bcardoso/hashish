;;; hashish.el --- wrapper for hash commands -*- lexical-binding: t -*-

;; Copyright (C) 2023 Bruno Cardoso

;; Author: Bruno Cardoso <cardoso.bc@gmail.com>
;; URL: https://github.com/bcardoso/hashish
;; Version: 0.1
;; Package-Requires: ((emacs "28.2"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Wrappers for xxHash, BLAKE2, and BLAKE3 commands:
;;
;; - https://github.com/Cyan4973/xxHash
;; - https://www.blake2.net
;; - https://github.com/BLAKE3-team/BLAKE3


;;; Code:

;;;; XXH

(defun hashish-xxhsum (string &optional hashtype)
  "Return the xxhsum of STRING.  Default algorithm is XXH64.

Optional argument HASHTYPE means 0=XXH32, 1=XXH64, 2=XXH128, 3=XXH3."
  (let* ((xxh (cond ((not hashtype) 1)
                    ((or (> hashtype 3) (< hashtype 0))
                     (user-error "ERROR.  Wrong XXH type: %s" hashtype))
                    (t hashtype)))
         (cmd (format "printf \"%s\" | xxhsum -H%s --tag" string xxh))
         (cut "cut -d\"=\" -f2 | tr -d \" \n\""))
    (shell-command-to-string (concat cmd "|" cut))))

(defun hashish-xxh32sum (string)
  "Return the xxh32sum of STRING."
  (hashish-xxhsum string 0))

(defun hashish-xxh64sum (string)
  "Return the xxh64sum of STRING."
  (hashish-xxhsum string 1))

(defun hashish-xxh128sum (string)
  "Return the xxh128sum of STRING."
  (hashish-xxhsum string 2))


;;;; BLAKE2

(defun hashish-b2sum (string &optional length)
  "Return the b2sum of STRING.  Default LENGTH is 512 bits.

Digest LENGTH in bits; must not exceed the max for the
blake2 algorithm and must be a multiple of 8."
  (let* ((len (cond ((not length) 512)
                    ((and (or (< length 8) (> length 64))
                          (not (eq (% length 8) 0)))
                     (user-error "ERROR.  Length must be a multiple of 8 between 8 and 64: %s" length))
                    (t length)))
         (cmd (format "printf \"%s\" | b2sum -l %s --tag" string len))
         (cut "cut -d\"=\" -f2 | tr -d \" \n\""))
    (shell-command-to-string (concat cmd "|" cut))))


;;;; BLAKE3

(defun hashish-b3sum (string &optional length)
  "Return the b2sum of STRING.  Default LENGTH 32 bytes."
  (let* ((len (cond ((not length) 32)
                    ((< length 1)
                     (user-error "ERROR.  Length must be a number of bytes"))
                    (t length)))
         (cmd (format "printf \"%s\" | b3sum -l %s --no-names" string len))
         (cut "tr -d \" \n\""))
    (shell-command-to-string (concat cmd "|" cut))))


(provide 'hashish)

;;; hashish.el ends here
