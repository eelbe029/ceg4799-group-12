package Validator with SPARK_Mode => On is

   Max_Len   : constant := 64;     --  taille du tampon
   Max_Input : constant := 4096;   --  taille max lue par le harnais

   subtype Length_Type is Natural  range 0 .. Max_Len;
   subtype Index_Type  is Positive range 1 .. Max_Len;

   --  Jeu de caracteres admissible (predicat de sous-type)
   subtype Safe_Char is Character with
     Static_Predicate =>
       Safe_Char in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '-' | '.';

   function Is_Safe (C : Character) return Boolean is (C in Safe_Char);

   type Buffer is array (Index_Type) of Character;

   type Result is (Accepted, Empty, Too_Long, Bad_Char);

   procedure Validate
     (Input  : String;
      Buf    : out Buffer;
      Len    : out Length_Type;
      Status : out Result)
   with
     Global  => null,
     Depends => (Buf => Input, Len => Input, Status => Input),
     Pre     => Input'First = 1 and then Input'Last <= Max_Input,
     Post    =>
       (Status = Too_Long) = (Input'Length > Max_Len)
       and then (Status = Empty) = (Input'Length = 0)
       and then
         (if Status = Accepted then
            Len = Input'Length
            and then (for all I in 1 .. Len =>
                        Buf (I) = Input (I) and then Is_Safe (Buf (I)))
          else
            Len = 0);

end Validator;
