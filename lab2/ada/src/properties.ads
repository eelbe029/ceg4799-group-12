package Properties is

   --  E8: Violated hypotheses from the C version (stack.c), written as
   --  explicit, verifiable properties. These prefigure the SPARK
   --  contracts to be proven in Labs 3-5.

   Max_Buffer_Length : constant := 12;  --  matches Buffer_Type in safe_bof.adb

   subtype Buffer_Index is Positive range 1 .. Max_Buffer_Length;

   --  Property 1: Admissible length domain.
   --  The C version assumed (without checking) that any caller-supplied
   --  string fits in the fixed buffer. This function makes that
   --  assumption an explicit, checkable predicate.
   function Length_In_Domain (Input_Length : Natural) return Boolean is
     (Input_Length <= Max_Buffer_Length);

   --  Property 2: Index bound.
   --  Every write into the buffer must target an index within
   --  1 .. Max_Buffer_Length. The C version had no such check; a
   --  SPARK contract would require this as a precondition on any
   --  indexing operation.
   function Index_In_Bounds (I : Integer) return Boolean is
     (I in Buffer_Index);

   --  Property 3: Buffer invariant.
   --  After any copy operation, the number of bytes actually written
   --  must never exceed the buffer's declared capacity. This is the
   --  core invariant strcpy() in C silently violates.
   function Buffer_Invariant
     (Bytes_Written : Natural) return Boolean is
     (Bytes_Written <= Max_Buffer_Length);

   --  Precondition wrapper mirroring what a SPARK contract would require
   --  on the copy routine itself:
   --    procedure Copy_Into_Buffer (Input : String)
   --      with Pre => Length_In_Domain (Input'Length);
   --  Demonstrated at runtime in safe_bof.adb via Constraint_Error.

end Properties;
