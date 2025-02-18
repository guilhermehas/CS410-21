{-# OPTIONS --guardedness #-}
module NowYouTry.FinalCoalgebras where

open import Data.Nat
open import Data.Product
open import Data.List using (List; []; _∷_)

---------------------------------------------------------------------------
-- Streams are final coalgebras
---------------------------------------------------------------------------

record Stream (A : Set) : Set where
  coinductive
  field
    head : A
    tail : Stream A
open Stream

F : {A : Set} -> Set -> Set
F {A} X = A × X

stream-coalg : {A : Set} -> Stream A -> A × Stream A
stream-coalg s = head s , tail s

unfold : {A : Set} -> {Y : Set} -> (Y -> A × Y) -> Y -> Stream A
head (unfold f y) = proj₁ (f y)
tail (unfold f y) = unfold f (proj₂ (f y))

---------------------------------------------------------------------------
-- Writing corecursive definitions
---------------------------------------------------------------------------

upFrom' : ℕ -> Stream ℕ
upFrom' = unfold λ n → n , suc n

upFrom : ℕ -> Stream ℕ
head (upFrom n) = n
tail (upFrom n) = upFrom (suc n)

take : {A : Set} -> ℕ -> Stream A -> List A
take zero s = []
take (suc n) s = head s ∷ take n (tail s)

test = take 500 (upFrom' 17)

Stream-map : {A B : Set} -> (f : A -> B) -> Stream A -> Stream B
head (Stream-map f s) = f (head s)
tail (Stream-map f s) = Stream-map f (tail s)

test' = take 400 (Stream-map (_+ 33) (upFrom 42))

---------------------------------------------------------------------------
-- Now You Try
---------------------------------------------------------------------------


record Tree (A : Set) : Set where
  coinductive
  field
    value : A
    left : Tree A
    right : Tree A
open Tree

repeat : {A : Set} -> A -> Tree A
value (repeat a) = a
left (repeat a) = repeat a
right (repeat a) = repeat a

Tree-map : {A B : Set} -> (A -> B) -> Tree A -> Tree B
value (Tree-map f tree) = f (value tree)
left (Tree-map f tree) = Tree-map f (left tree)
right (Tree-map f tree) = Tree-map f (right tree)
