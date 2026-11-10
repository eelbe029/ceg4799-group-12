package body Validator with SPARK_Mode => On is

   procedure Validate
     (Input  : String;
      Buf    : out Buffer;
      Len    : out Length_Type;
      Status : out Result)
   is
   begin
      Buf := (others => ' ');
      Len := 0;

      if Input'Length = 0 then
         Status := Empty;
         return;
      end if;

      if Input'Length > Max_Len then
         Status := Too_Long;
         return;
      end if;

      for I in 1 .. Input'Length loop
         if not Is_Safe (Input (I)) then
            Buf    := (others => ' ');
            Status := Bad_Char;
            return;
         end if;
         Buf (I) := Input (I);
         pragma Loop_Invariant
           (for all J in 1 .. I =>
              Is_Safe (Input (J)) and then Buf (J) = Input (J));
      end loop;

      Len    := Input'Length;
      Status := Accepted;
   end Validate;

end Validator;
