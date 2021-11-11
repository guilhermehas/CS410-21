{-# OPTIONS --type-in-type #-}
module NowYouTry.FunctorsAndNatTransformations where

open import Data.List as List
open import Data.Maybe as Maybe
open import Function
open import Relation.Binary.PropositionalEquality hiding ([_])

open import Axiom.Extensionality.Propositional
open import Axiom.UniquenessOfIdentityProofs.WithK

open import Common.Category hiding (idFunctor; compFunctor)

open import Lectures.Categories

open Category
open Functor
open NaturalTransformation

---------------------------------------------------------------------------
-- Trees are functors
---------------------------------------------------------------------------

data Tree (X : Set) : Set where
  leaf : Tree X
  _<[_]>_ : Tree X -> X -> Tree X -> Tree X

tree-map : ∀ {X Y : Set} → (f : X -> Y) -> Tree X -> Tree Y
tree-map f leaf = leaf
tree-map f (l <[ x ]> r) = tree-map f l <[ f x ]> tree-map f r

TREE : Functor SET SET
act TREE X = Tree X
fmap TREE f = tree-map f
identity TREE = ext p where
  p : ∀ {X : Set} (t : Tree X) → fmap TREE (λ x → x) t ≡ t
  p leaf = refl
  p (l <[ x ]> r) rewrite p l | p r = refl
homomorphism TREE = ext p where
  p : ∀ {X Y Z : Set}{f : X -> Y}{g : Y -> Z} (t : Tree X) → fmap TREE (comp SET f g) t ≡ fmap TREE g(fmap TREE f t)
  p leaf = refl
  p (l <[ x ]> r) = cong₂ (λ z w → z <[ _ ]> w) (p l) (p r)

--------------------------------------------------------------------------
-- Forgetful mappings are functors
---------------------------------------------------------------------------

forgetMonoid : Functor MONOID SET
act forgetMonoid M = Monoid.Carrier M
fmap forgetMonoid f = MonoidMorphism.fun f
identity forgetMonoid = refl
homomorphism forgetMonoid = refl

--------------------------------------------------------------------------
-- Kit for proving functors equal
---------------------------------------------------------------------------

eqFunctor : {C D : Category}{F G : Functor C D} ->
            (p : act F ≡ act G) -> (∀ {A B} → subst (λ z → Hom C A B -> Hom D (z A) (z B)) p (fmap F) ≡ (fmap G {A} {B})) -> F ≡ G
eqFunctor {C} {D} {F} {G} refl q with iext (λ {A} → iext (λ {B} → q {A} {B}))
  where   iext = implicit-extensionality ext
... | refl = eqFunctor' {G = G} (implicit-extensionality ext λ {A} → uip _ _) (iext (iext (iext (iext (iext (uip _ _)))))) where
  iext = implicit-extensionality ext
  eqFunctor' : ∀ {C} {D} {G : Functor C D}
               {identity' identity'' : {A : Obj C} → fmap G {A} (Category.id C) ≡ Category.id D}
               {homomorphism' homomorphism'' : {X Y Z : Obj C} {f : Hom C X Y} {g : Hom C Y Z} → fmap G (comp C f g) ≡ comp D (fmap G f) (fmap G g)} →
               (_≡_ {A = ∀ {A} → fmap G {A} (Category.id C) ≡ Category.id D} identity' identity'') ->
               (_≡_ {A = {X Y Z : Obj C} {f : Hom C X Y} {g : Hom C Y Z} → fmap G (comp C f g) ≡ comp D (fmap G f) (fmap G g)} homomorphism' homomorphism'') ->
             _≡_ {A = Functor C D} (record { act = act G; fmap = fmap G; identity = identity'; homomorphism = homomorphism' })
                                   (record { act = act G; fmap = fmap G; identity = identity''; homomorphism = homomorphism'' })
  eqFunctor' refl refl = refl

--------------------------------------------------------------------------
-- The category of categories
---------------------------------------------------------------------------

idFunctor : {C : Category} -> Functor C C
act idFunctor X = X
fmap idFunctor f = f
identity idFunctor = refl
homomorphism idFunctor = refl

compFunctor : {A B C : Category} -> Functor A B → Functor B C → Functor A C
act (compFunctor F G) = comp SET (act F) (act G)
fmap (compFunctor F G) f = fmap G (fmap F f)
identity (compFunctor F G) = trans (cong (fmap G) (identity F)) (identity G)
homomorphism (compFunctor F G) = trans (cong (fmap G) (homomorphism F)) (homomorphism G)

CAT : Category
Obj CAT = Category
Hom CAT = Functor
Category.id CAT = idFunctor
comp CAT = compFunctor
assoc CAT = eqFunctor refl refl
identityˡ CAT = eqFunctor refl refl
identityʳ CAT = eqFunctor refl refl

--------------------------------------------------------------------------
-- root is a natural transformation
---------------------------------------------------------------------------

MAYBE : Functor SET SET
act MAYBE = Maybe
fmap MAYBE = Maybe.map
identity MAYBE = ext λ { nothing → refl ; (just x) → refl }
homomorphism MAYBE = ext λ { nothing → refl ; (just x) → refl }

root : NaturalTransformation TREE MAYBE
transform root X leaf = nothing
transform root X (l <[ x ]> r) = just x
natural root X Y f = ext λ { leaf → refl ; (l <[ x ]> r) → refl }

--------------------------------------------------------------------------
-- Now You Try
---------------------------------------------------------------------------

LIST : Functor SET SET
act LIST = List
fmap LIST = List.map
identity LIST = ext α
  where
    α : ∀ {A} (xs : List A) → List.map (Category.id SET) xs ≡ Function.id xs
    α [] = refl
    α (x ∷ xs) = cong₂ _∷_ refl (α xs)
homomorphism LIST = ext α where
  α : ∀ {X f g} (x : List X) →
      List.map {_} {X} ((SET Category.∘ g) f) x ≡
      (SET Category.∘ List.map g) (List.map f) x
  α [] = refl
  α (x ∷ xs) = cong₂ _∷_ refl (α xs)

flatten : (X : Set) -> Tree X -> List X
flatten X leaf = []
flatten X (l <[ x ]> r) = flatten X l ++ [ x ] ++ flatten X r

flattenNT : NaturalTransformation TREE LIST
transform flattenNT _ tree = flatten _ tree
natural flattenNT X Y f = ext α where
  map-++ : ∀ {A B f} (xs ys : List A)
    → List.map {_} {A} {_} {B} f (xs ++ ys) ≡ List.map f xs ++ List.map f ys
  map-++ [] ys = refl
  map-++ (x ∷ xs) ys = cong₂ _∷_ refl (map-++ xs ys)

  α : (tree : Tree X) →
      (SET Category.∘ (flatten Y)) (fmap TREE f) tree ≡
      (SET Category.∘ List.map f) (flatten X) tree
  α leaf = refl
  α (l <[ x ]> r) with α l | α r
  ... | eq1 | eq2 rewrite map-++ {f = f} (flatten X l) (x ∷ flatten X r)
    = cong₂ _++_ eq1 (cong₂ _∷_ refl eq2)
