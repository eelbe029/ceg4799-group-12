--  Harnais d'essai : HORS SPARK, isole derriere l'interface du paquet Validator
with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Strings;
with Ada.Strings.Fixed;
with Validator;

procedure Harness with SPARK_Mode => Off is
   Line : String (1 .. Validator.Max_Input);
   Last : Natural;
   Buf  : Validator.Buffer;
   Len  : Validator.Length_Type;
   St   : Validator.Result;
begin
   Get_Line (Line, Last);
   Validator.Validate (Line (1 .. Last), Buf, Len, St);
   Put_Line (Validator.Result'Image (St) & " len="
             & Ada.Strings.Fixed.Trim (Natural'Image (Len), Ada.Strings.Left));
exception
   when End_Error =>
      Put_Line ("EMPTY len=0");
end Harness;
