(*
   This file is part of BubbleStorm.
   Copyright © 2008-2013 the BubbleStorm authors

   BubbleStorm is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   BubbleStorm is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with BubbleStorm.  If not, see <http://www.gnu.org/licenses/>.
*)

structure WhirlpoolRaw : COMPRESSOR_RAW =
   struct
      val sbox = Byte.stringToBytes
         "\024\035\198\232\135\184\001\079\054\166\210\245\121\111\145\082\
         \\096\188\155\142\163\012\123\053\029\224\215\194\046\075\254\087\
         \\021\119\055\229\159\240\074\218\088\201\041\010\177\160\107\133\
         \\189\093\016\244\203\062\005\103\228\039\065\139\167\125\149\216\
         \\251\238\124\102\221\023\071\158\202\045\191\007\173\090\131\051\
         \\099\002\170\113\200\025\073\217\242\227\091\136\154\038\050\176\
         \\233\015\213\128\190\205\052\072\255\122\144\095\032\104\026\174\
         \\180\084\147\034\100\241\115\018\064\008\195\236\219\161\141\061\
         \\151\000\207\043\118\130\214\027\181\175\106\080\069\243\048\239\
         \\063\085\162\234\101\186\047\192\222\028\253\077\146\117\006\138\
         \\178\230\014\031\098\212\168\150\249\197\037\089\132\114\057\076\
         \\094\120\056\140\209\165\226\097\179\033\156\030\067\199\252\004\
         \\081\153\109\013\250\223\126\036\059\171\206\017\143\078\183\235\
         \\060\129\148\247\185\019\044\211\231\110\196\003\086\068\127\169\
         \\042\187\193\083\220\011\157\108\049\116\246\070\172\137\020\225\
         \\022\058\105\009\112\182\208\237\204\066\152\164\040\092\248\134"

      infix 6 ^^ &&
      infix 7 << >>
      val op ^^ = Word64.xorb
      val op && = Word64.andb
      val op << = Word64.<<
      val op >> = Word64.>>
      
      fun C0f i =
         let
            fun dbl x =
               Word8.xorb (Word8.<< (x, 0w1),
                           if Word8.andb (x, 0wx80) = 0w0 then 0w0 else 0wx1d)
            val v1 = Word8Vector.sub (sbox, i)
            val v2 = dbl v1
            val v4 = dbl v2
            val v5 = Word8.xorb (v4, v1)
            val v8 = dbl v4
            val v9 = Word8.xorb (v8, v1)
            val f = Word64.fromLarge o Word8.toLarge
         in
            f v1 << 0w56 ^^ f v1 << 0w48 ^^ f v4 << 0w40 ^^ f v1 << 0w32 ^^
            f v8 << 0w24 ^^ f v5 << 0w16 ^^ f v2 << 0w8  ^^ f v9
         end
      val C0t = Word64Vector.tabulate (256, C0f)
      
(*
      fun ror shift i = 
         MLton.Word64.ror (Word64Vector.sub (C0t, i), shift)
*)
      
      fun ror shift =
         let
            fun f x = x >> shift ^^ x << (0w64 - shift)
            val table = Word64Vector.map f C0t
         in
            fn i => Word64Vector.sub (table, i)
         end
      
      fun C0 i = Word64Vector.sub (C0t, i)
      val C1 = ror 0w8
      val C2 = ror 0w16
      val C3 = ror 0w24
      val C4 = ror 0w32
      val C5 = ror 0w40
      val C6 = ror 0w48
      val C7 = ror 0w56
      
      val R = 10
      fun rcf i =
         let
            val i = 8*i
         in
            (C0 (i+0) && 0wxff00000000000000) ^^
            (C1 (i+1) && 0wx00ff000000000000) ^^
            (C2 (i+2) && 0wx0000ff0000000000) ^^
            (C3 (i+3) && 0wx000000ff00000000) ^^
            (C4 (i+4) && 0wx00000000ff000000) ^^
            (C5 (i+5) && 0wx0000000000ff0000) ^^
            (C6 (i+6) && 0wx000000000000ff00) ^^
            (C7 (i+7) && 0wx00000000000000ff)
         end
      val rct = Word64Vector.tabulate (R, rcf)
      fun rc i = Word64Vector.sub (rct, i)
      
      fun xor ((x0, x1, x2, x3, x4, x5, x6, x7),
               (y0, y1, y2, y3, y4, y5, y6, y7)) =
            (x0 ^^ y0, x1 ^^ y1, x2 ^^ y2, x3 ^^ y3,
             x4 ^^ y4, x5 ^^ y5, x6 ^^ y6, x7 ^^ y7)
      
      fun xor0 ((x0, x1, x2, x3, x4, x5, x6, x7), y) =
         (x0 ^^ y, x1, x2, x3, x4, x5, x6, x7)
      
      fun matrix (x0, x1, x2, x3, x4, x5, x6, x7) =
         let
            val cut = Word8.toInt o Word8.fromLarge o Word64.toLarge
            fun f (y0, y1, y2, y3, y4, y5, y6, y7) =
               C0 (cut (y0 >> 0w56)) ^^
               C1 (cut (y1 >> 0w48)) ^^
               C2 (cut (y2 >> 0w40)) ^^
               C3 (cut (y3 >> 0w32)) ^^
               C4 (cut (y4 >> 0w24)) ^^
               C5 (cut (y5 >> 0w16)) ^^
               C6 (cut (y6 >> 0w8)) ^^
               C7 (cut y7)
         in
            (f (x0, x7, x6, x5, x4, x3, x2, x1),
             f (x1, x0, x7, x6, x5, x4, x3, x2),
             f (x2, x1, x0, x7, x6, x5, x4, x3),
             f (x3, x2, x1, x0, x7, x6, x5, x4),
             f (x4, x3, x2, x1, x0, x7, x6, x5),
             f (x5, x4, x3, x2, x1, x0, x7, x6),
             f (x6, x5, x4, x3, x2, x1, x0, x7),
             f (x7, x6, x5, x4, x3, x2, x1, x0))
         end
      
      fun debug _ = ()
(*
      fun debug ((K0, K1, K2, K3, K4, K5, K6, K7),
                 (S0, S1, S2, S3, S4, S5, S6, S7)) =
         let
            fun str w =
               if w < 0w16 then ^ ("0", Word8.toString w) else Word8.toString w
            fun dump x =
               let
                  fun b s = str (Word8.fromLarge (Word64.toLarge (x >> s)))
               in
                  concat [ b 0w56, " ", b 0w48, " ", b 0w40, " ", b 0w32, " ",
                           b 0w24, " ", b 0w16, " ", b 0w8,  " ", b 0w0 ]
               end
            val l = [
               "K:                             state:\n",
               "      ", dump K0, "      ", dump S0, "\n",
               "      ", dump K1, "      ", dump S1, "\n",
               "      ", dump K2, "      ", dump S2, "\n",
               "      ", dump K3, "      ", dump S3, "\n",
               "      ", dump K4, "      ", dump S4, "\n",
               "      ", dump K5, "      ", dump S5, "\n",
               "      ", dump K6, "      ", dump S6, "\n",
               "      ", dump K7, "      ", dump S7, "\n"]
         in
            print (concat l)
         end
*)
      
      type state = 
         Word64.word * Word64.word * Word64.word * Word64.word *
         Word64.word * Word64.word * Word64.word * Word64.word
      
      local
         open Serial
         val w64x8b = aggregate tuple8
            `word64b `word64b `word64b `word64b
            `word64b `word64b `word64b `word64b $
      in
         val { parseSlice, parseVector, writeSlice, ... } = methods w64x8b
      end
      
      fun compress (hash, block) =
         let
            fun round (i, (K, state)) = 
               if i = R then state else
               let
                  val () = debug (K, state)
                  val K = matrix K
                  val K = xor0 (K, rc i)
                  val state = matrix state
                  val state = xor (state, K)
               in
                  round (i+1, (K, state))
               end
               
            val state = round (0, (hash, xor (block, hash)))
         in
            xor (hash, xor (state, block))
         end
      
      fun compressA (S, a) = compress (S, parseSlice a)
      fun compressV (S, v) = compress (S, parseVector v)
      
      val inputLength  = 64
      val outputLength = 64
      
      val z : Word64.word = 0w0
      val initial = (z, z, z, z, z, z, z, z)
      fun finish (x, s) = writeSlice (s, x)
      
      local
         open Serial
         (* ... omg. 256-bit length counter. -.- *)
         val w64x4 = aggregate tuple4 `word64b `word64b `word64b `word64b $
      in
         val length = Serial.map {
            store = fn x => (0w0, 0w0, 0w0, Word64.* (x, 0w8)),
            load  = fn (_, _, _, x) => Word64.div (x, 0w8),
            extra = fn () => ()
         } w64x4
      end
   end

structure WhirlpoolCooked = Compressor(WhirlpoolRaw)

(*
fun test str =
   let
      val bytes = Byte.stringToBytes str
      val hash = WhirlpoolCooked.hash bytes
      val result = WordToString.fromBytes hash
   in
      print ("Hash(" ^ str ^ ") =\n     " ^ result ^ "\n")
   end

val () = test ""
val () = test "a"
val () = test "abc"
val () = test "message digest"
val () = test "abcdefghijklmnopqrstuvwxyz"
val () = test "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
val () = test "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
(*val () = test (CharVector.tabulate (1000000, fn _ => #"a"))*)
val () = test "The quick brown fox jumps over the lazy dog"
*)

(* Test vectors from running Whirlpool.java from http://www.larc.usp.br/~pbarreto/WhirlpoolPage.html
"" (empty string) 	19FA61D75522A4669B44E39C1D2E1726C530232130D407F89AFEE0964997F7A73E83BE698B288FEBCF88E3E03C4F0757EA8964E59B63D93708B138CC42A66EB3
"a"			8ACA2602792AEC6F11A67206531FB7D7F0DFF59413145E6973C45001D0087B42D11BC645413AEFF63A42391A39145A591A92200D560195E53B478584FDAE231A
"abc"			4E2448A4C6F486BB16B6562C73B4020BF3043E3A731BCE721AE1B303D97E6D4C7181EEBDB6C57E277D0E34957114CBD6C797FC9D95D8B582D225292076D4EEF5
"message digest"  	378C84A4126E2DC6E56DCC7458377AAC838D00032230F53CE1F5700C0FFB4D3B8421557659EF55C106B4B52AC5A4AAA692ED920052838F3362E86DBD37A8903E
"a...z"1 		F1D754662636FFE92C82EBB9212A484A8D38631EAD4238F5442EE13B8054E41B08BF2A9251C30B6A0B8AAE86177AB4A6F68F673E7207865D5D9819A3DBA4EB3B
"A...Za...z0...9"3 	DC37E008CF9EE69BF11F00ED9ABA26901DD7C28CDEC066CC6AF42E40F82F3A1E08EBA26629129D8FB7CB57211B9281A65517CC879D7B962142C65F5A7AF01467
8 times "1234567890" 	466EF18BABB0154D25B9D38A6414F5C08784372BCCB204D6549C4AFADB6014294D5BD8DF2A6C44E538CD047B2681A51A2C60481E88C5A20B2C2A80CF3A9A083B
1 million times "a" 	0C99005BEB57EFF50A7CF005560DDF5D29057FD86B20BFD62DECA0F1CCEA4AF51FC15490EDDC47AF32BB2B66C34FF9AD8C6008AD677F77126953B226E4ED8B01
*)
