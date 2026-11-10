with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions; use Ada.Exceptions;

procedure Safe_Bof is

   --  Mirrors the vulnerable C buffer: char buffer[12];
   --  Ada's constrained subtype enforces the bound at runtime.
   subtype Buffer_Type is String (1 .. 12);

   Buffer : Buffer_Type;

   --  Simulates the malicious oversized input used in the C exploit (E3/E5).
   Malicious_Input : constant String :=
     "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

   procedure Bof (Input : String) is
   begin
      --  Direct assignment into the fixed-size buffer.
      --  If Input'Length > Buffer'Length, Ada raises Constraint_Error
      --  instead of overflowing adjacent stack memory, as strcpy() does in C.
      Buffer (1 .. Input'Length) := Input;
      Put_Line ("Copied safely: " & Buffer (1 .. Input'Length));
   end Bof;

begin
   Put_Line ("Testing with the malicious E3/E5 payload (" &
             Integer'Image (Malicious_Input'Length) & " bytes)...");
   begin
      Bof (Malicious_Input);
   exception
      when Error : Constraint_Error =>
         Put_Line ("Blocked: Constraint_Error raised -- " &
                   Exception_Message (Error));
   end;

   Put_Line ("Testing with a safe, properly sized input...");
   begin
      Bof ("short input");
      Put_Line ("Accepted as expected.");
   exception
      when Error : Constraint_Error =>
         Put_Line ("Unexpected rejection: " & Exception_Message (Error));
   end;
end Safe_Bof;
