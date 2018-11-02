\begin{code}

{-# OPTIONS --without-K --allow-unsolved-metas #-}

module Lecture08 where

import Lecture07
open Lecture07 public

-- Section 8.1 Propositions

is-prop : {i : Level} (A : UU i) → UU i
is-prop A = (x y : A) → is-contr (Id x y)

is-prop-empty : is-prop empty
is-prop-empty ()

is-prop-unit : is-prop unit
is-prop-unit = is-prop-is-contr is-contr-unit

is-prop' : {i : Level} (A : UU i) → UU i
is-prop' A = (x y : A) → Id x y

is-prop-is-prop' : {i : Level} {A : UU i} → is-prop' A → is-prop A
is-prop-is-prop' {i} {A} H x y =
  dpair
    (concat _ (inv (H x x)) (H x y))
    (ind-Id x
      (λ z p → Id (concat _ (inv (H x x)) (H x z)) p)
      (left-inv (H x x)) y)

is-prop'-is-prop : {i : Level} {A : UU i} → is-prop A → is-prop' A
is-prop'-is-prop H x y = pr1 (H x y)

is-contr-is-prop-inh : {i : Level} {A : UU i} → is-prop A → A → is-contr A
is-contr-is-prop-inh H a = dpair a (is-prop'-is-prop H a)

is-prop-is-contr-if-inh : {i : Level} {A : UU i} → (A → is-contr A) → is-prop A
is-prop-is-contr-if-inh H x y = is-prop-is-contr (H x) x y

is-subtype : {i j : Level} {A : UU i} (B : A → UU j) → UU (i ⊔ j)
is-subtype B = (x : _) → is-prop (B x)

-- Section 8.2 Sets

is-set : {i : Level} → UU i → UU i
is-set A = (x y : A) → is-prop (Id x y)

axiom-K : {i : Level} → UU i → UU i
axiom-K A = (x : A) (p : Id x x) → Id refl p

is-set-axiom-K : {i : Level} (A : UU i) → axiom-K A → is-set A
is-set-axiom-K A H x y =
  is-prop-is-prop' (ind-Id x (λ z p → (q : Id x z) → Id p q) (H x) y)

axiom-K-is-set : {i : Level} (A : UU i) → is-set A → axiom-K A
axiom-K-is-set A H x p =
  concat
    (center (is-contr-is-prop-inh (H x x) refl))
      (inv (contraction (is-contr-is-prop-inh (H x x) refl) refl))
      (contraction (is-contr-is-prop-inh (H x x) refl) p)

is-equiv-prop-in-id : {i j : Level} {A : UU i}
  (R : A → A → UU j)
  (p : (x y : A) → is-prop (R x y))
  (ρ : (x : A) → R x x)
  (i : (x y : A) → R x y → Id x y)
  → (x y : A) → is-equiv (i x y)
is-equiv-prop-in-id R p ρ i x =
  id-fundamental-retr x (i x)
    (λ y → dpair
      (ind-Id x (λ z p → R x z) (ρ x) y)
      ((λ r → is-prop'-is-prop (p x y) _ r)))

is-prop-is-equiv : {i j : Level} {A : UU i} (B : UU j)
  (f : A → B) (E : is-equiv f) → is-prop B → is-prop A
is-prop-is-equiv B f E H x y =
  is-contr-is-equiv _ (ap f {x} {y}) (is-emb-is-equiv f E x y) (H (f x) (f y))

is-prop-is-equiv' : {i j : Level} (A : UU i) {B : UU j}
  (f : A → B) (E : is-equiv f) → is-prop A → is-prop B
is-prop-is-equiv' A f E H =
  is-prop-is-equiv _ (inv-is-equiv E) (is-equiv-inv-is-equiv E) H

is-set-prop-in-id : {i j : Level} {A : UU i}
  (R : A → A → UU j)
  (p : (x y : A) → is-prop (R x y))
  (ρ : (x : A) → R x x)
  (i : (x y : A) → R x y → Id x y)
  → is-set A
is-set-prop-in-id R p ρ i x y =
  is-prop-is-equiv' (R x y) (i x y) (is-equiv-prop-in-id R p ρ i x y) (p x y)

is-prop-Eq-ℕ : (n m : ℕ) → is-prop (Eq-ℕ n m)
is-prop-Eq-ℕ zero-ℕ zero-ℕ = is-prop-unit
is-prop-Eq-ℕ zero-ℕ (succ-ℕ m) = is-prop-empty
is-prop-Eq-ℕ (succ-ℕ n) zero-ℕ = is-prop-empty
is-prop-Eq-ℕ (succ-ℕ n) (succ-ℕ m) = is-prop-Eq-ℕ n m

is-set-ℕ : is-set ℕ
is-set-ℕ =
  is-set-prop-in-id
    Eq-ℕ
    is-prop-Eq-ℕ
    reflexive-Eq-ℕ
    (least-reflexive-Eq-ℕ (λ n → refl))

-- Section 8.3 General truncation levels

data 𝕋 : UU lzero where
  neg-two-𝕋 : 𝕋
  succ-𝕋 : 𝕋 → 𝕋

neg-one-𝕋 : 𝕋
neg-one-𝕋 = succ-𝕋 (neg-two-𝕋)

zero-𝕋 : 𝕋
zero-𝕋 = succ-𝕋 (neg-one-𝕋)

one-𝕋 : 𝕋
one-𝕋 = succ-𝕋 (zero-𝕋)

ℕ-in-𝕋 : ℕ → 𝕋
ℕ-in-𝕋 zero-ℕ = zero-𝕋
ℕ-in-𝕋 (succ-ℕ n) = succ-𝕋 (ℕ-in-𝕋 n)

-- Probably it is better to define this where we first need it.
add-𝕋 : 𝕋 → 𝕋 → 𝕋
add-𝕋 neg-two-𝕋 neg-two-𝕋 = neg-two-𝕋
add-𝕋 neg-two-𝕋 (succ-𝕋 neg-two-𝕋) = neg-two-𝕋
add-𝕋 neg-two-𝕋 (succ-𝕋 (succ-𝕋 y)) = y
add-𝕋 (succ-𝕋 neg-two-𝕋) neg-two-𝕋 = neg-two-𝕋
add-𝕋 (succ-𝕋 neg-two-𝕋) (succ-𝕋 y) = y
add-𝕋 (succ-𝕋 (succ-𝕋 neg-two-𝕋)) y = y
add-𝕋 (succ-𝕋 (succ-𝕋 (succ-𝕋 x))) y = succ-𝕋 (add-𝕋 (succ-𝕋 (succ-𝕋 x)) y)

is-trunc : {i : Level} (k : 𝕋) → UU i → UU i
is-trunc neg-two-𝕋 A = is-contr A
is-trunc (succ-𝕋 k) A = (x y : A) → is-trunc k (Id x y)
  
is-trunc-succ-is-trunc : {i : Level} (k : 𝕋) (A : UU i) →
  is-trunc k A → is-trunc (succ-𝕋 k) A
is-trunc-succ-is-trunc neg-two-𝕋 A H = is-prop-is-contr H
is-trunc-succ-is-trunc (succ-𝕋 k) A H =
  λ x y → is-trunc-succ-is-trunc k (Id x y) (H x y)

is-trunc-is-equiv : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j}
  (f : A → B) → is-equiv f → is-trunc k B → is-trunc k A
is-trunc-is-equiv neg-two-𝕋 f is-equiv-f H =
  is-contr-is-equiv _ f is-equiv-f H
is-trunc-is-equiv (succ-𝕋 k) f is-equiv-f H x y =
  is-trunc-is-equiv k (ap f {x} {y})
    (is-emb-is-equiv f is-equiv-f x y) (H (f x) (f y))

is-trunc-is-equiv' : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j}
  (f : A → B) → is-equiv f → is-trunc k A → is-trunc k B
is-trunc-is-equiv' k f is-equiv-f is-trunc-A =
  is-trunc-is-equiv k
    ( inv-is-equiv is-equiv-f)
    ( is-equiv-inv-is-equiv is-equiv-f)
    ( is-trunc-A)

is-trunc-succ-is-emb : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j}
  (f : A → B) → is-emb f → is-trunc (succ-𝕋 k) B → is-trunc (succ-𝕋 k) A
is-trunc-succ-is-emb k f Ef H x y =
  is-trunc-is-equiv k (ap f {x} {y}) (Ef x y) (H (f x) (f y))

is-trunc-map : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j} →
  (A → B) → UU (i ⊔ j)
is-trunc-map k f = (y : _) → is-trunc k (fib f y)

is-trunc-pr1-is-trunc-fam : {i j : Level} (k : 𝕋) {A : UU i} (B : A → UU j) →
  ((x : A) → is-trunc k (B x)) → is-trunc-map k (pr1 {i} {j} {A} {B})
is-trunc-pr1-is-trunc-fam k B H x =
  is-trunc-is-equiv k
    ( fib-fam-fib-pr1 B x)
    ( is-equiv-fib-fam-fib-pr1 B x)
    ( H x)

is-trunc-fam-is-trunc-pr1 : {i j : Level} (k : 𝕋) {A : UU i} (B : A → UU j) →
  is-trunc-map k (pr1 {i} {j} {A} {B}) → ((x : A) → is-trunc k (B x))
is-trunc-fam-is-trunc-pr1 k B is-trunc-pr1 x =
  is-trunc-is-equiv k
    ( fib-pr1-fib-fam B x)
    ( is-equiv-fib-pr1-fib-fam B x)
    ( is-trunc-pr1 x)

is-trunc-map-is-trunc-ap : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j}
  (f : A → B) → ((x y : A) → is-trunc-map k (ap f {x = x} {y = y})) →
  is-trunc-map (succ-𝕋 k) f
is-trunc-map-is-trunc-ap k f is-trunc-ap-f b (dpair x p) (dpair x' p') =
  is-trunc-is-equiv k
    ( fib-ap-eq-fib f (dpair x p) (dpair x' p'))
    ( is-equiv-fib-ap-eq-fib f (dpair x p) (dpair x' p'))
    ( is-trunc-ap-f x x' (concat _ p (inv p')))

is-trunc-ap-is-trunc-map : {i j : Level} (k : 𝕋) {A : UU i} {B : UU j}
  (f : A → B) → is-trunc-map (succ-𝕋 k) f →
  (x y : A) → is-trunc-map k (ap f {x = x} {y = y})
is-trunc-ap-is-trunc-map k f is-trunc-map-f x y p =
  is-trunc-is-equiv' k
    ( eq-fib-fib-ap f x y p)
    ( is-equiv-eq-fib-fib-ap f x y p)
    ( is-trunc-map-f (f y) (dpair x p) (dpair y refl))

is-prop-map : {i j : Level} {A : UU i} {B : UU j} (f : A → B) → UU (i ⊔ j)
is-prop-map f = (b : _) → is-trunc neg-one-𝕋 (fib f b)

is-emb-is-prop-map : {i j : Level} {A : UU i} {B : UU j} (f : A → B) →
  is-prop-map f → is-emb f
is-emb-is-prop-map f is-prop-map-f x y =
  is-equiv-is-contr-map
    ( is-trunc-ap-is-trunc-map neg-two-𝕋 f is-prop-map-f x y)

is-prop-map-is-emb : {i j : Level} {A : UU i} {B : UU j} (f : A → B) →
  is-emb f → is-prop-map f
is-prop-map-is-emb f is-emb-f =
  is-trunc-map-is-trunc-ap neg-two-𝕋 f
    ( λ x y → is-contr-map-is-equiv (is-emb-f x y))

is-emb-pr1-is-subtype : {i j : Level} {A : UU i} {B : A → UU j} →
  is-subtype B → is-emb (pr1 {B = B})
is-emb-pr1-is-subtype is-subtype-B =
  is-emb-is-prop-map pr1
    ( λ x → is-trunc-is-equiv neg-one-𝕋
      ( fib-fam-fib-pr1 _ x)
      ( is-equiv-fib-fam-fib-pr1 _ x)
      ( is-subtype-B x))

is-subtype-is-emb-pr1 : {i j : Level} {A : UU i} {B : A → UU j} →
  is-emb (pr1 {B = B}) → is-subtype B
is-subtype-is-emb-pr1 is-emb-pr1-B x =
  is-trunc-is-equiv neg-one-𝕋
    ( fib-pr1-fib-fam _ x)
    ( is-equiv-fib-pr1-fib-fam _ x)
    ( is-prop-map-is-emb pr1 is-emb-pr1-B x)

is-fiberwise-trunc : {l1 l2 l3 : Level} (k : 𝕋)  {A : UU l1} {B : A → UU l2}
  {C : A → UU l3} (f : (x : A) → B x → C x) → UU (l1 ⊔ (l2 ⊔ l3))
is-fiberwise-trunc k f = (x : _) → is-trunc-map k (f x)

is-trunc-tot-is-fiberwise-trunc : {l1 l2 l3 : Level} (k : 𝕋)
  {A : UU l1} {B : A → UU l2} {C : A → UU l3} (f : (x : A) → B x → C x) →
  is-fiberwise-trunc k f → is-trunc-map k (tot f)
is-trunc-tot-is-fiberwise-trunc k f is-fiberwise-trunc-f (dpair x z) =
  is-trunc-is-equiv k
    ( fib-ftr-fib-tot f (dpair x z))
    ( is-equiv-fib-ftr-fib-tot f (dpair x z))
    ( is-fiberwise-trunc-f x z)

is-fiberwise-trunc-is-trunc-tot : {l1 l2 l3 : Level} (k : 𝕋)
  {A : UU l1} {B : A → UU l2} {C : A → UU l3} (f : (x : A) → B x → C x) →
  is-trunc-map k (tot f) → is-fiberwise-trunc k f
is-fiberwise-trunc-is-trunc-tot k f is-trunc-tot-f x z =
  is-trunc-is-equiv k
    ( fib-tot-fib-ftr f (dpair x z))
    ( is-equiv-fib-tot-fib-ftr f (dpair x z))
    ( is-trunc-tot-f (dpair x z))

-- Exercises

-- Exercise 8.1

diagonal : {l : Level} (A : UU l) → A → A × A
diagonal A x = dpair x x

is-prop-is-equiv-diagonal : {l : Level} (A : UU l) →
  is-equiv (diagonal A) → is-prop A
is-prop-is-equiv-diagonal A is-equiv-d =
  is-prop-is-prop' ( λ x y →
    let α = issec-inv-is-equiv is-equiv-d (dpair x y) in
    ( inv (ap pr1 α)) ∙ (ap pr2 α))

eq-fib-diagonal : {l : Level} (A : UU l) (t : A × A) →
  fib (diagonal A) t → Id (pr1 t) (pr2 t)
eq-fib-diagonal A (dpair x y) (dpair z α) = (inv (ap pr1 α)) ∙ (ap pr2 α)

fib-diagonal-eq : {l : Level} (A : UU l) (t : A × A) →
  Id (pr1 t) (pr2 t) → fib (diagonal A) t
fib-diagonal-eq A (dpair x y) β =
  dpair x (eq-pair-triv (pair x x) (pair x y) (dpair refl β))

issec-fib-diagonal-eq : {l : Level} (A : UU l) (t : A × A) →
  ((eq-fib-diagonal A t) ∘ (fib-diagonal-eq A t)) ~ id
issec-fib-diagonal-eq A (dpair x .x) refl = refl

isretr-fib-diagonal-eq : {l : Level} (A : UU l) (t : A × A) →
  ((fib-diagonal-eq A t) ∘ (eq-fib-diagonal A t)) ~ id
isretr-fib-diagonal-eq A .(dpair z z) (dpair z refl) = refl

is-equiv-eq-fib-diagonal : {l : Level} (A : UU l) (t : A × A) →
  is-equiv (eq-fib-diagonal A t)
is-equiv-eq-fib-diagonal A t =
  is-equiv-has-inverse
    ( dpair
      ( fib-diagonal-eq A t)
      ( dpair (issec-fib-diagonal-eq A t) (isretr-fib-diagonal-eq A t)))

is-trunc-is-trunc-diagonal : {l : Level} (k : 𝕋) (A : UU l) →
  is-trunc-map k (diagonal A) → is-trunc (succ-𝕋 k) A
is-trunc-is-trunc-diagonal k A is-trunc-d x y =
  is-trunc-is-equiv' k
    ( eq-fib-diagonal A (dpair x y))
    ( is-equiv-eq-fib-diagonal A (dpair x y))
    ( is-trunc-d (dpair x y))

is-trunc-diagonal-is-trunc : {l : Level} (k : 𝕋) (A : UU l) →
  is-trunc (succ-𝕋 k) A → is-trunc-map k (diagonal A)
is-trunc-diagonal-is-trunc k A is-trunc-A t =
  is-trunc-is-equiv k
    ( eq-fib-diagonal A t)
    ( is-equiv-eq-fib-diagonal A t)
    ( is-trunc-A (pr1 t) (pr2 t))

-- Exercise 8.2

is-contr-Σ : {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  is-contr A → ((x : A) → is-contr (B x)) → is-contr (Σ A B)
is-contr-Σ {A = A} {B = B} is-contr-A is-contr-B =
  is-contr-is-equiv'
    ( B (center is-contr-A))
    ( left-unit-law-Σ-map B is-contr-A)
    ( is-equiv-left-unit-law-Σ-map B is-contr-A)
    ( is-contr-B (center is-contr-A))

is-trunc-Σ : {l1 l2 : Level} (k : 𝕋) {A : UU l1} {B : A → UU l2} →
  is-trunc k A → ((x : A) → is-trunc k (B x)) → is-trunc k (Σ A B)
is-trunc-Σ neg-two-𝕋 is-trunc-A is-trunc-B =
  is-contr-Σ is-trunc-A is-trunc-B
is-trunc-Σ (succ-𝕋 k) {B = B} is-trunc-A is-trunc-B s t =
  is-trunc-is-equiv k pair-eq
    ( is-equiv-pair-eq' s t)
    ( is-trunc-Σ k
      ( is-trunc-A (pr1 s) (pr1 t))
      ( λ p → is-trunc-B (pr1 t) (tr B p (pr2 s)) (pr2 t)))

is-trunc-prod : {l1 l2 : Level} (k : 𝕋) {A : UU l1} {B : UU l2} →
  is-trunc k A → is-trunc k B → is-trunc k (A × B)
is-trunc-prod k is-trunc-A is-trunc-B =
  is-trunc-Σ k is-trunc-A (λ x → is-trunc-B)

-- Exercise 8.3

is-prop-Eq-𝟚 : (x y : bool) → is-prop (Eq-𝟚 x y)
is-prop-Eq-𝟚 true true = is-prop-unit
is-prop-Eq-𝟚 true false = is-prop-empty
is-prop-Eq-𝟚 false true = is-prop-empty
is-prop-Eq-𝟚 false false = is-prop-unit

eq-Eq-𝟚 : (x y : bool) → Eq-𝟚 x y → Id x y
eq-Eq-𝟚 true true star = refl
eq-Eq-𝟚 true false ()
eq-Eq-𝟚 false true ()
eq-Eq-𝟚 false false star = refl

is-set-bool : is-set bool
is-set-bool = is-set-prop-in-id Eq-𝟚 is-prop-Eq-𝟚 reflexive-Eq-𝟚 eq-Eq-𝟚

-- Exercise 8.4

is-trunc-succ-empty : (k : 𝕋) → is-trunc (succ-𝕋 k) empty
is-trunc-succ-empty k = ind-empty

is-trunc-coprod : {l1 l2 : Level} (k : 𝕋) {A : UU l1} {B : UU l2} →
  is-trunc (succ-𝕋 (succ-𝕋 k)) A → is-trunc (succ-𝕋 (succ-𝕋 k)) B →
  is-trunc (succ-𝕋 (succ-𝕋 k)) (coprod A B)
is-trunc-coprod k {A} {B} is-trunc-A is-trunc-B (inl x) (inl y) =
  is-trunc-is-equiv (succ-𝕋 k)
    ( Eq-coprod-eq A B (inl x) (inl y))
    ( is-equiv-Eq-coprod-eq A B (inl x) (inl y))
    ( is-trunc-is-equiv' (succ-𝕋 k)
      ( map-raise _ (Id x y))
      ( is-equiv-map-raise _ (Id x y))
      ( is-trunc-A x y))
is-trunc-coprod k {A} {B} is-trunc-A is-trunc-B (inl x) (inr y) =
   is-trunc-is-equiv (succ-𝕋 k)
     ( Eq-coprod-eq A B (inl x) (inr y))
     ( is-equiv-Eq-coprod-eq A B (inl x) (inr y))
     ( is-trunc-is-equiv' (succ-𝕋 k)
       ( map-raise _ empty)
       ( is-equiv-map-raise _ empty)
       ( is-trunc-succ-empty k))
is-trunc-coprod k {A} {B} is-trunc-A is-trunc-B (inr x) (inl y) =
  is-trunc-is-equiv (succ-𝕋 k)
    ( Eq-coprod-eq A B (inr x) (inl y))
    ( is-equiv-Eq-coprod-eq A B (inr x) (inl y))
    ( is-trunc-is-equiv' (succ-𝕋 k)
      ( map-raise _ empty)
      ( is-equiv-map-raise _ empty)
      ( is-trunc-succ-empty k))
is-trunc-coprod k {A} {B} is-trunc-A is-trunc-B (inr x) (inr y) =
   is-trunc-is-equiv (succ-𝕋 k)
     ( Eq-coprod-eq A B (inr x) (inr y))
     ( is-equiv-Eq-coprod-eq A B (inr x) (inr y))
     ( is-trunc-is-equiv' (succ-𝕋 k)
       ( map-raise _ (Id x y))
       ( is-equiv-map-raise _ (Id x y))
       ( is-trunc-B x y))

is-set-coprod : {l1 l2 : Level} {A : UU l1} {B : UU l2} →
  is-set A → is-set B → is-set (coprod A B)
is-set-coprod = is-trunc-coprod neg-two-𝕋

is-set-unit : is-set unit
is-set-unit = is-trunc-succ-is-trunc neg-one-𝕋 unit is-prop-unit

is-set-ℤ : is-set ℤ
is-set-ℤ = is-set-coprod is-set-ℕ (is-set-coprod is-set-unit is-set-ℕ)

-- Exercise 8.5

has-decidable-equality : {l : Level} (A : UU l) → UU l
has-decidable-equality A = (x y : A) → coprod (Id x y) (¬ (Id x y))

split-decidable-equality : {l : Level} (A : UU l) (x y : A) →
  coprod (Id x y) (¬ (Id x y)) → UU lzero
split-decidable-equality A x y (inl p) = unit
split-decidable-equality A x y (inr f) = empty

is-prop-split-decidable-equality : {l : Level} (A : UU l) (x y : A) →
  (t : coprod (Id x y) (¬ (Id x y))) →
  is-prop (split-decidable-equality A x y t)
is-prop-split-decidable-equality A x y (inl p) = is-prop-unit
is-prop-split-decidable-equality A x y (inr f) = is-prop-empty

reflexive-split-decidable-equality : {l : Level} (A : UU l) (x : A) →
  (t : coprod (Id x x) (¬ (Id x x))) → split-decidable-equality A x x t
reflexive-split-decidable-equality A x (inl p) = star
reflexive-split-decidable-equality A x (inr f) =
  ind-empty {P = λ t → split-decidable-equality A x x (inr f)} (f refl)

eq-split-decidable-equality : {l : Level} (A : UU l) (x y : A) →
  (t : coprod (Id x y) (¬ (Id x y))) →
  split-decidable-equality A x y t → Id x y
eq-split-decidable-equality A x y (inl p) t = p
eq-split-decidable-equality A x y (inr f) t = ind-empty {P = λ s → Id x y} t 

Eq-decidable-equality : {l : Level} (A : UU l) (d : has-decidable-equality A) →
  A → A → UU lzero
Eq-decidable-equality A d x y = split-decidable-equality A x y (d x y)

is-set-has-decidable-equality : {l : Level} (A : UU l) →
  has-decidable-equality A → is-set A
is-set-has-decidable-equality A d =
  is-set-prop-in-id
    ( λ x y → split-decidable-equality A x y (d x y))
    ( λ x y → is-prop-split-decidable-equality A x y (d x y))
    ( λ x → reflexive-split-decidable-equality A x (d x x))
    ( λ x y → eq-split-decidable-equality A x y (d x y))

\end{code}
