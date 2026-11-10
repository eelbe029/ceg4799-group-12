--  CEG 4799 / CSI 4539 - Lab 3
--  Input validation module, rewritten in SPARK from the vulnerable C routine
--  (untrusted input copied into a fixed-size buffer).
--
--  Every validation hypothesis is written as an explicit contract (E3):
--    * bounded length     -> constrained subtypes Length_Type / Buffer_String
--    * index bound        -> constrained subtype Buffer_Index
--    * admissible charset -> subtype predicate on Allowed_Char
--    * buffer invariant   -> postcondition of Validate

package Input_Validator
  with SPARK_Mode => On
is

   --  Capacity of the fixed-size destination buffer (char buffer[64] in C).
   Max_Length : constant := 64;

   --  Largest raw input the caller may hand over (fread bound of lab 2:
   --  char str[517]).
   Max_Raw_Length : constant := 517;

   ---------------------------------------------------------------------
   --  Constrained subtypes: length and index hypotheses
   ---------------------------------------------------------------------

   --  Number of characters stored in the buffer: never more than capacity.
   subtype Length_Type is Natural range 0 .. Max_Length;

   --  Any index used to write into the buffer.
   subtype Buffer_Index is Positive range 1 .. Max_Length;

   --  Bounded string: the destination buffer itself.
   subtype Buffer_String is String (Buffer_Index);

   ---------------------------------------------------------------------
   --  Subtype predicate: admissible character set
   ---------------------------------------------------------------------

   --  Only letters, digits, '_', '-' and '.' are admissible. Shell
   --  metacharacters (; | & $ ` / space ...), format-string characters (%)
   --  and control characters (NUL, newline ...) are all outside the set.
   subtype Allowed_Char is Character
     with Static_Predicate =>
       Allowed_Char in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '-' | '.';

   --  Value used to fill the unused part of the buffer.
   Pad : constant Character := ' ';

   --  Decision returned by the validator.
   type Status_Type is
     (Accepted,            --  input is valid and has been copied
      Rejected_Empty,      --  input has length 0
      Rejected_Too_Long,   --  input does not fit in the buffer
      Rejected_Bad_Char);  --  input contains a character outside the set

   ---------------------------------------------------------------------
   --  Validation policy, as executable specification functions
   ---------------------------------------------------------------------

   --  True when every character of S belongs to the admissible set.
   function All_Allowed (S : String) return Boolean is
     (for all I in S'Range => S (I) in Allowed_Char)
   with Global => null;

   --  The complete policy: bounded, non-empty, admissible characters only.
   function Is_Valid (Input : String) return Boolean is
     (Input'Length in 1 .. Max_Length and then All_Allowed (Input))
   with Global => null;

   ---------------------------------------------------------------------
   --  Validation subprogram
   ---------------------------------------------------------------------

   --  Validates the untrusted Input and, only if it is valid, copies it
   --  into Buffer.
   --
   --  Global  : the subprogram reads and writes no global state.
   --  Depends : each output depends on Input only.
   --  Pre     : Input is indexed from 1 and is at most Max_Raw_Length long
   --            (constraint on the representation, not on the content).
   --  Post    : Accepted exactly when the policy holds; an accepted input
   --            fits in the buffer and is an exact copy made of admissible
   --            characters only; a rejected input stores nothing.
   procedure Validate
     (Input  : in     String;
      Buffer :    out Buffer_String;
      Length :    out Length_Type;
      Status :    out Status_Type)
   with
     Global  => null,
     Depends => (Buffer => Input,
                 Length => Input,
                 Status => Input),
     Pre     => Input'First = 1 and then Input'Last <= Max_Raw_Length,
     Post    =>
       (Status = Accepted) = Is_Valid (Input)
       and then
         (case Status is
            when Accepted =>
               Length = Input'Length
               and then (for all I in 1 .. Length =>
                           Buffer (I) = Input (I)
                           and then Buffer (I) in Allowed_Char),
            when Rejected_Empty =>
               Input'Length = 0 and then Length = 0,
            when Rejected_Too_Long =>
               Input'Length > Max_Length and then Length = 0,
            when Rejected_Bad_Char =>
               Input'Length in 1 .. Max_Length
               and then not All_Allowed (Input)
               and then Length = 0);

end Input_Validator;
