Feature: W0786

  W0786 detects that a bit-field whose base type is not in signed or unsigned
  `int' is declared.

  Scenario: typedefed `unsigned long' bit-field declaration
    Given a target source named "fixture.c" with:
      """
      typedef unsigned long base_t;
      
      static struct { /* W0786 */
          base_t    :1; /* bit padding */
          base_t foo:1;
          base_t    :1; /* bit padding */
          base_t bar:1;
          base_t    :1; /* bit padding */
      } bf;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0786 | 3    | 8      |

  Scenario: typedefed `unsigned int' bit-field declaration
    Given a target source named "fixture.c" with:
      """
      typedef unsigned int base_t;
      
      static struct { /* OK */
          base_t    :1; /* bit padding */
          base_t foo:1;
          base_t    :1; /* bit padding */
          base_t bar:1;
          base_t    :1; /* bit padding */
      } bf;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
