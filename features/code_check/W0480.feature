Feature: W0480

  W0480 detects that the macro defines operator, punctuation character or
  control statements.

  Scenario: defines the operator
    Given a target source named "fixture.c" with:
      """
      #define OP_1 + /* W0480 */
      #define OP_2 * /* W0480 */
      #define OP_3 ~ /* W0480 */
      #define OP_4 -- /* W0480 */
      #define OP_5 / /* W0480 */
      #define OP_6 << /* W0480 */
      #define OP_7 && /* W0480 */
      #define OP_8 /= /* W0480 */
      #define OP_9 ^= /* W0480 */
      #define OP_0 : /* W0480 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0480 | 1    | 1      |
      | W0480 | 2    | 1      |
      | W0480 | 3    | 1      |
      | W0480 | 4    | 1      |
      | W0480 | 5    | 1      |
      | W0480 | 6    | 1      |
      | W0480 | 7    | 1      |
      | W0480 | 8    | 1      |
      | W0480 | 9    | 1      |
      | W0480 | 10   | 1      |

  Scenario: defines a punctuation character
    Given a target source named "fixture.c" with:
      """
      #define PC_1 [ /* W0480 */
      #define PC_2 ( /* W0480 */
      #define PC_3 { /* W0480 */
      #define PC_4 * /* W0480 */
      #define PC_5 , /* W0480 */
      #define PC_6 : /* W0480 */
      #define PC_7 = /* W0480 */
      #define PC_8 ; /* W0480 */
      #define PC_9 ... /* W0480 */
      #define PC_0 # /* W0480 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0477 | 1    | 1      |
      | W0477 | 2    | 1      |
      | W0477 | 3    | 1      |
      | W0480 | 1    | 1      |
      | W0480 | 2    | 1      |
      | W0480 | 3    | 1      |
      | W0480 | 4    | 1      |
      | W0480 | 5    | 1      |
      | W0480 | 6    | 1      |
      | W0480 | 7    | 1      |
      | W0480 | 8    | 1      |
      | W0480 | 9    | 1      |
      | W0480 | 10   | 1      |

  Scenario: defines a control statement
    Given a target source named "fixture.c" with:
      """
      #define CS_01 if /* W0480 */
      #define CS_02 else /* W0480 */
      #define CS_03 switch /* W0480 */
      #define CS_04 case /* W0480 */
      #define CS_05 default /* W0480 */
      #define CS_06 break /* W0480 */
      #define CS_07 continue /* W0480 */
      #define CS_08 while /* W0480 */
      #define CS_09 do /* W0480 */
      #define CS_10 for /* W0480 */
      #define CS_11 goto /* W0480 */
      #define CS_12 return /* W0480 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0480 | 1    | 1      |
      | W0480 | 2    | 1      |
      | W0480 | 3    | 1      |
      | W0480 | 4    | 1      |
      | W0480 | 5    | 1      |
      | W0480 | 6    | 1      |
      | W0480 | 7    | 1      |
      | W0480 | 8    | 1      |
      | W0480 | 9    | 1      |
      | W0480 | 10   | 1      |
      | W0480 | 11   | 1      |
      | W0480 | 12   | 1      |

  Scenario: defines the pair of punctuation character
    Given a target source named "fixture.c" with:
      """
      #define PC_1 [] /* OK */
      #define PC_2 () /* OK */
      #define PC_3 {} /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: defines operator and control statements
    Given a target source named "fixture.c" with:
      """
      #define IF(x) if((x)==0)return 1;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0478 | 1    | 1      |
