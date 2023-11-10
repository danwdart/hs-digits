module Main (main) where

import Data.Digits
import Test.QuickCheck
import Text.Printf

-- | unDigits . digits should be the identity, in any positive base.
prop_digitsRoundTrip
    ∷ Integer -- ^ The integer to test.
    → Integer -- ^ The base to use.
    → Property
prop_digitsRoundTrip i b = i > 0 ==> b > 0 ==> i == (unDigits b . digits b) i

tests ∷ [([Char], IO ())]
tests = [
    ("checkDigitsRoundTrip", quickCheck prop_digitsRoundTrip)]

main ∷ IO ()
main = mapM_ (\(s,a) -> printf "%-25s: " s >> a) tests

