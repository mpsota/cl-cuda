#|
  This file is a part of cl-cuda project.
  Copyright (c) 2012 Masayuki Takagi (kamonama@gmail.com)
|#

(in-package :cl-user)
(defpackage cl-cuda.lang.environment
  (:use :cl
        :cl-cuda.lang.data
        :cl-cuda.lang.type)
  (:export ;; Variable environment
           :empty-variable-environment
           ;; Variable environment - Variable
           :variable-environment-add-variable
           :variable-environment-variable-exists-p
           :variable-environment-variable-name
           :variable-environment-variable-type
           ;; Variable environment - Symbol macro
           :variable-environment-add-symbol-macro
           :variable-environment-symbol-macro-exists-p
           :variable-environment-symbol-macro-name
           :variable-environment-symbol-macro-expansion
           ;; Function environment
           :empty-function-environment
           ;; Function environment - Function
           :function-environment-add-function
           :function-environment-function-exists-p
           :function-environment-function-name
           :function-environment-function-return-type
           :function-environment-function-argument-types
           ;; Function environment - Macro
           :function-environment-add-macro
           :function-environment-macro-exists-p
           :function-environment-macro-name
           :function-environment-macro-expander))
(in-package :cl-cuda.lang.environment)


;;;
;;; Variable environment
;;;

(defun empty-variable-environment ()
  nil)


;;;
;;; Variable environment - Variable
;;;

(defun variable-environment-add-variable (name type var-env)
  (let ((elem (make-variable name type)))
    (acons name elem var-env)))

(defun variable-environment-variable-exists-p (var-env name)
  (variable-p (cdr (assoc name var-env))))

(defun %lookup-variable (var-env name)
  (unless (variable-environment-variable-exists-p var-env name)
    (error "The variable ~S not found." name))
  (cdr (assoc name var-env)))

(defun variable-environment-variable-name (var-env name)
  (variable-name (%lookup-variable var-env name)))

(defun variable-environment-variable-type (var-env name)
  (variable-type (%lookup-variable var-env name)))


;;;
;;; Variable environment - Symbol macro
;;;

(defun variable-environment-add-symbol-macro (name expansion var-env)
  (let ((elem (make-symbol-macro name expansion)))
    (acons name elem var-env)))

(defun variable-environment-symbol-macro-exists-p (var-env name)
  (symbol-macro-p (cdr (assoc name var-env))))

(defun %lookup-symbol-macro (var-env name)
  (unless (variable-environment-symbol-macro-exists-p var-env name)
    (error "The symbol macro ~S not found." name))
  (cdr (assoc name var-env)))

(defun variable-environment-symbol-macro-name (var-env name)
  (symbol-macro-name (%lookup-symbol-macro var-env name)))

(defun variable-environment-symbol-macro-expansion (var-env name)
  (symbol-macro-expansion (%lookup-symbol-macro var-env name)))


;;;
;;; Function environment
;;;

(defun empty-function-environment ()
  '())


;;;
;;; Function environment - Function
;;;

(defun function-environment-add-function (name return-type
                                          argument-types func-env)
  (let ((elem (make-function name return-type argument-types)))
    (acons name elem func-env)))

(defun function-environment-function-exists-p (func-env name)
  (function-p (cdr (assoc name func-env))))

(defun %lookup-function (func-env name)
  (unless (function-environment-function-exists-p func-env name)
    (error "The function ~S is undefined." name))
  (cdr (assoc name func-env)))

(defun function-environment-function-name (func-env name)
  (function-name (%lookup-function func-env name)))

(defun function-environment-function-return-type (func-env name)
  (function-return-type (%lookup-function func-env name)))

(defun function-environment-function-argument-types (func-env name)
  (function-argument-types (%lookup-function func-env name)))


;;;
;;; Function environment - Macro
;;;

(defun function-environment-add-macro (name expander func-env)
  (let ((elem (make-macro name expander)))
    (acons name elem func-env)))

(defun function-environment-macro-exists-p (func-env name)
  (macro-p (cdr (assoc name func-env))))

(defun %lookup-macro (func-env name)
  (unless (function-environment-macro-exists-p func-env name)
    (error "The macro ~S is undefined." name))
  (cdr (assoc name func-env)))

(defun function-environment-macro-name (func-env name)
  (macro-name (%lookup-macro func-env name)))

(defun function-environment-macro-expander (func-env name)
  (macro-expander (%lookup-macro func-env name)))


;;;
;;; Variable
;;;

;; use name begining with '%' to avoid package locking
(defstruct (%variable (:constructor %make-variable)
                      (:conc-name variable-)
                      (:predicate variable-p))
  (name :name :read-only t)
  (type :type :read-only t))

(defun make-variable (name type)
  (unless (cl-cuda-symbol-p name)
    (error 'type-error :datum name :expected-type 'cl-cuda-symbol))
  (unless (cl-cuda-type-p type)
    (error 'type-error :datum type :expected-type 'cl-cuda-type))
  (%make-variable :name name :type type))


;;;
;;; Symbol macro
;;;

(defstruct (symbol-macro (:constructor %make-symbol-macro))
  (name :name :read-only t)
  (expansion :expansion :read-only t))

(defun make-symbol-macro (name expansion)
  (unless (cl-cuda-symbol-p name)
    (error 'type-error :datum name :expected-type 'cl-cuda-symbol))
  (%make-symbol-macro :name name :expansion expansion))


;;;
;;; Function
;;;

;; use name begining with '%' to avoid package locking
(defstruct (%function (:constructor %make-function)
                      (:conc-name function-)
                      (:predicate function-p))
  (name :name :read-only t)
  (return-type :return-type :read-only t)
  (argument-types :argument-types :read-only t))

(defun make-function (name return-type argument-types)
  (unless (cl-cuda-symbol-p name)
    (error 'type-error :datum name :expected-type 'cl-cuda-symbol))
  (unless (cl-cuda-type-p return-type)
    (error 'type-error :datum return-type :expected-type 'cl-cuda-type))
  (dolist (argument-type argument-types)
    (unless (cl-cuda-type-p argument-type)
      (error 'type-error :datum argument-type
                         :expected-type 'cl-cuda-type)))
  (%make-function :name name
                  :return-type return-type
                  :argument-types argument-types))


;;;
;;; Macro
;;;

(defstruct (macro (:constructor %make-macro))
  (name :name :read-only t)
  (expander :expander :read-only t))

(defun make-macro (name expander)
  (unless (cl-cuda-symbol-p name)
    (error 'type-error :datum name :expected-type 'cl-cuda-symbol))
  (%make-macro :name name :expander expander))
