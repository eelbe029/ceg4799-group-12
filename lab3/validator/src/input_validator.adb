--  CEG 4799 / CSI 4539 - Lab 3
--  Body of the SPARK input validator. Written from scratch: no C code reused.

package body Input_Validator
  with SPARK_Mode => On
is

   procedure Validate
     (Input  : in     String;
      Buffer :    out Buffer_String;
      Length :    out Length_Type;
      Status :    out Status_Type)
   is
   begin
      --  Every "out" parameter gets a value on every path (flow analysis).
      Buffer := (others => Pad);
      Length := 0;

      if Input'Length = 0 then
         Status := Rejected_Empty;

      elsif Input'Length > Max_Length then
         --  Length is checked BEFORE any write: nothing is copied.
         Status := Rejected_Too_Long;

      elsif not All_Allowed (Input) then
         Status := Rejected_Bad_Char;

      else
         --  Here 1 <= Input'Length <= Max_Length, so every I is a valid
         --  Buffer_Index: the copy cannot overflow the buffer.
         for I in Input'Range loop
            Buffer (I) := Input (I);
            pragma Loop_Invariant
              (for all J in 1 .. I => Buffer (J) = Input (J));
         end loop;

         Length := Input'Length;
         Status := Accepted;
      end if;
   end Validate;

end Input_Validator;
