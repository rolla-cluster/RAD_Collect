# RAD_Collect
Recursive Azure Active Directory User collection script in Powershell. 


--SourceGroup:
--------User A
--------User B
--------Group 1
-------------User C
-------------User D
-------------Group 2
-----------------User E
-----------------User F
      | |
      | |
      | |
      \ /
       v

--AggregateGroup:
--------User A
--------User B
--------User C
--------User D
--------User E
--------User F
