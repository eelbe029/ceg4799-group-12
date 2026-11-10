--  CEG 4799 / CSI 4539 - Lab 3
--  Test harness for Input_Validator.
--
--  NON-SPARK CODE: this unit does text output and exception handling, so it
--  is explicitly excluded from the proof (SPARK_Mode => Off). It only talks
--  to the validator through the interface of package Input_Validator.
--
--  Built with -gnata: every Pre, Post and subtype predicate of the validator
--  is checked at run time while the test cases execute.

with Ada.Assertions;
with Ada.Command_Line;
with Ada.Text_IO;      use Ada.Text_IO;
with Input_Validator;  use Input_Validator;

procedure Test_Validator
  with SPARK_Mode => Off
is

   Passed : Natural := 0;
   Failed : Natural := 0;

   --  Run one test case and compare the decision with the expected one.
   procedure Run (Name : String; Input : String; Expected : Status_Type) is
      Buffer : Buffer_String;
      Length : Length_Type;
      Status : Status_Type;
   begin
      Validate (Input, Buffer, Length, Status);

      if Status = Expected then
         Passed := Passed + 1;
         Put ("[PASS] ");
      else
         Failed := Failed + 1;
         Put ("[FAIL] ");
      end if;

      Put (Name);
      Set_Col (38);
      Put ("len =" & Integer'Image (Input'Length));
      Set_Col (49);
      Put ("-> " & Status_Type'Image (Status));

      if Status = Accepted then
         Put ("  buffer = """ & Buffer (1 .. Length) & """");
      end if;
      New_Line;
   end Run;

   --  Assign a character to the predicated subtype: with -gnata the
   --  predicate of Allowed_Char is checked here.
   procedure Check_Predicate (C : Character) is
   begin
      declare
         A : constant Allowed_Char := C;
      begin
         Put_Line ("  '" & A & "' satisfies the Allowed_Char predicate");
      end;
   exception
      when Ada.Assertions.Assertion_Error =>
         Put_Line ("  '" & C & "' violates the Allowed_Char predicate"
                   & " -> Assertion_Error raised (check is active)");
   end Check_Predicate;

   A_64  : constant String (1 .. 64)  := (others => 'A');
   A_65  : constant String (1 .. 65)  := (others => 'A');
   A_517 : constant String (1 .. 517) := (others => 'A');

begin
   Put_Line ("=== Input_Validator: test cases (built with -gnata) ===");

   --  Valid inputs
   Run ("valid: simple word",          "hello",            Accepted);
   Run ("valid: file name",            "user_01.txt",      Accepted);
   Run ("valid: all allowed classes",  "A-b.C_9",          Accepted);

   --  Boundaries
   Run ("bound: 1 char",               "a",                Accepted);
   Run ("bound: 64 chars (max)",       A_64,               Accepted);
   Run ("bound: 65 chars (max + 1)",   A_65,               Rejected_Too_Long);
   Run ("bound: empty input",          "",                 Rejected_Empty);

   --  Out-of-range length (overflow payload size of lab 2)
   Run ("overflow: 517 chars (lab 2)", A_517,              Rejected_Too_Long);

   --  Injection payloads (corpus of labs 1 and 2)
   Run ("inject: ';' second command",
        "/dev/null; /usr/bin/touch /tmp/CORPUS_PROOF",     Rejected_Bad_Char);
   Run ("inject: $(...) substitution",
        "$(/usr/bin/touch /tmp/CORPUS_PROOF)",             Rejected_Bad_Char);
   Run ("inject: backticks",           "`id`",             Rejected_Bad_Char);
   Run ("inject: pipe",                "a|id",             Rejected_Bad_Char);
   Run ("inject: format string",       "%x%x%x%n",         Rejected_Bad_Char);
   Run ("inject: path traversal",      "../../etc/passwd", Rejected_Bad_Char);
   Run ("inject: space",               "a b",              Rejected_Bad_Char);
   Run ("inject: embedded NUL",
        "abc" & Character'Val (0) & "def",                 Rejected_Bad_Char);
   Run ("inject: newline",
        "abc" & Character'Val (10) & "id",                 Rejected_Bad_Char);

   New_Line;
   Put_Line ("=== Contracts are checked at run time (-gnata) ===");

   --  Subtype predicate
   Check_Predicate ('a');
   Check_Predicate (';');

   --  Precondition: a slice that does not start at index 1 violates
   --  Pre => Input'First = 1.
   declare
      Text   : constant String := "xxabcdxx";
      Buffer : Buffer_String;
      Length : Length_Type;
      Status : Status_Type;
   begin
      Validate (Text (3 .. 6), Buffer, Length, Status);
      Put_Line ("  precondition NOT checked: status = "
                & Status_Type'Image (Status)
                & ", length =" & Integer'Image (Length)
                & ", first = '" & Buffer (1) & "'"
                & " (was the harness built without -gnata?)");
      Failed := Failed + 1;
   exception
      when Ada.Assertions.Assertion_Error =>
         Put_Line ("  call with Input'First = 3 violates the precondition"
                   & " -> Assertion_Error raised (check is active)");
   end;

   New_Line;
   Put_Line ("Result:" & Natural'Image (Passed) & " passed,"
             & Natural'Image (Failed) & " failed");

   if Failed > 0 then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Test_Validator;
