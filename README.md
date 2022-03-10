# RAD_Collect
Recursive Azure Active Directory User collection script in Powershell. 


--SourceGroup:<br>
--------User A<br>
--------User B<br>
--------Group 1<br>
-------------User C<br>
-------------User D<br>
-------------Group 2<br>
-----------------User E<br>
-----------------User F<br>
      | |<br>
      | |<br>
      | |<br>
      \ /<br>
       v<br>

--AggregateGroup:<br>
--------User A<br>
--------User B<br>
--------User C<br>
--------User D<br>
--------User E<br>
--------User F<br>
