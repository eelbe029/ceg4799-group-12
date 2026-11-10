pragma SPARK_Mode (Off);
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with Input_Validator; use Input_Validator;

procedure Compare_Harness is
   Input  : constant String := Argument (1);
   Buffer : Buffer_String;
   Length : Length_Type;
   Status : Status_Type;
begin
   Validate (Input, Buffer, Length, Status);
   case Status is
      when Accepted =>
         Put_Line ("ACCEPTED len=" & Length_Type'Image (Length));
      when Rejected_Empty =>
         Put_Line ("REJECTED_EMPTY");
      when Rejected_Too_Long =>
         Put_Line ("REJECTED_TOO_LONG");
      when Rejected_Bad_Char =>
         Put_Line ("REJECTED_BAD_CHAR");
   end case;
end Compare_Harness;
