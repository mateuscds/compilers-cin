/* ------------------------------------- ALUNO: MATEUS CAVALCANTI DOS SANTOS  --------------------------------------*/

/* nome da gramática -- deve ser o mesmo nome do arquivo .g4 e começar com letra maiúscula*/
grammar Grammar;

/* ---------------------------------------------- parser ----------------------------------------------------*/


// Regra file: pode ser tanto definição de variavel seguida de ponto e virgula quanto uma definição de função 

file: (function_definition | variable_definition ';')*;  


// Regra function_definition: precisa do tipo, seguido do indenficador (nome da função, etc), argumentos e o corpo da função (body)

function_definition: type identifier arguments body;


//Regra array: int function(int x, int y), etc
function_call: identifier '(' (expression (',' expression)* )* ')';


// Regra arguments: representa os argumentos da função. Ex: int func(int x, int y)
arguments: '(' (type identifier)? (',' type identifier)* ')'; 


// Regra body: o corpo da função contendo apenas o statement
body: '{' statement* '}';


/*  Regra statement: necessário ser feita nessa ordem, já que primeiro sao vistas as definiçoes de variavel, depois
	as atribuições, seguidas de possível returns, expressões, condicionais if/else, loops e por fim o corpo da função. */

statement:    variable_definition ';'  
		   	| variable_assignment ';'
			| 'return' expression ';' 
			| expression ';' 
			| if_statement 
			| for_loop
			| body;


//Regra if_statement: abrange os diferentes tipos de condicional (apenas if, if else, if{}, else{})
if_statement: 'if' '(' expression ')' (body | statement) else_statement?;


//Regra else_statement: abrange os diferentes tipos de else (else{}, else, etc)
else_statement: 'else' (body | statement);


//Regra for_loop: abrange a estrutura for( ; ; )
for_loop: 'for' '(' for_initializer ';' for_condition ';' for_step ')' (body | statement);


//Regra for_initializer: temos a presença do "?" pois o for pode ser definido sem inicializador (ex: i = 0)
for_initializer: (variable_definition | variable_assignment)?;


//Regra for_condition: temos a presença do "?" pois o for pode ser definido sem condicional (ex: i<5)
for_condition: expression?; 


//Regra for_step: temos a presença do "?" pois o for pode ser definido sem incremento (ex: i++)
for_step: variable_assignment?;


//Regra array: v[10], v[i]
array: identifier '[' expression ']';


//Regra array: {1,2,3}, etc. Aceita tanto apenas um {1}, quanto mais de um {1,2,3,etc}
array_literal: '{' expression (',' expression)* '}';


//Regra variable_definition: possibilidades de declaração de variável (ex; int x = 0, y = 0, v[10])
variable_definition:  type (identifier ('=' expression)?) (',' (identifier ('=' expression)? ) )*
					| type (identifier ('=' expression)?) (',' (array ('=' array_literal)? ) )*
					| type array ('=' array_literal)? (',' (identifier ('=' expression)? ) )*
					| type array ('=' array_literal)? (',' (array ('=' array_literal)? ) )*;


//Regra variable_assignment: assignment como x += 5, v[i] = 10, i++, etc.
variable_assignment:  identifier '=' expression 
					| identifier ('/='|'*=') expression 
					| identifier ('+='|'-=') expression 
					| identifier ('++'|'--')
					| ('++'|'--') identifier
					| array '=' expression 
					| array ('/='|'*=') expression 
					| array ('+='|'-=') expression 
					| array ('++'|'--')
					| ('++'|'--') array;


//Regra expression: x < y, 10, 6.7
expression:  integer | floating | string
			| identifier | array
			| function_call
			| expression ('<'|'>'|'<='|'>='|'!='|'==') expression                 // expressões lógicas devem vir após expressões aritméticas
			| ('-'|'+') expression                                                //sinal deve ter precedencia sobre qualquer operação. Ex: -(15 * 6 - 4)
			| expression ('*'|'/') expression | expression ('+'|'-') expression   //aqui é necessário obedecer a ordem de prescedênca, já que divisao e multiplicação vem antes de soma e substração
			| '(' expression ')';


// Regra type: representa os tipos de variáveis. Ex: int, float
type: TYPE;


// Regra identifier: representa os identificadores
identifier: IDENTIFIER;


//Regras de tipos
string : STRING;    // tipo string
floating : FLOAT;   // tipo float
integer : INTEGER;  // tipo inteiro


/* ------------------------------------------------ lexer ------------------------------------------------  */  

WHITESPACE: [ \t\n] -> skip ;		     // espaços em branco (seja ' ', tab ou quebra de linha)
BREAKLINE : ('\r' '\n'? | '\n') -> skip; // quebra de linha
LINE_COMMENT: '//' .*? '\n' -> skip ;    // procura  até a quebra de linha (por isso o uso do '?')
ALL_COMMENT: '/*' .*? '*/' -> skip ;     // procura até o símbolo */
DEFINE: '#' ~[\r\n]* -> skip;            // reconhece qualquer diretiva até a quebra de linha
TYPE: ('int'|'float');                   // apenas tipos de declaração
INTEGER: [0-9]+;               		     // Cada inteiro precisa ter pelo menos um número (não vazio)
FLOAT : [0-9]+'.'[0-9]+;     		     // precisa ter pelo menos um número antes do ponto e outro número depois do ponto. Ex: 2.0
STRING: '"' .*? '"';         		     // após '"' envolve qualquer coisa e procura pelo próximo '"'. 
IDENTIFIER: [a-zA-Z_]+[a-zA-Z_0-9]* ;    // reconhece todos os caracteres a-z, A-Z e digitos 0-9, de modo que caso existam digitos, sempre é necessaário um caracter a-z ou A-Z antes

/*
MANUAL

caracteres especiais para expressões regulares {
	'xyz'   :  os caracteres rodeados por ' ' são interpretados literalmente 
	\x		:  altera a interpretação do caracter x, se ele tiver outra (\t: tab, \(: o caracter que abre parênteses)
	a(bc)d  :  destaca a subexpressão bc
	x | y   :  aceita a subexpressão x ou y
	[x\yz]	:  equivalente a ('x'|\y|'z'), tal que x, \y e z são caracteres
	[x]		:  equivalente a 'x'
	x*		:  aceita 0 ou mais x's
	x+		:  aceita 1 ou mais x's
	x?		:  aceita 0 ou 1 x
	.       :  aceita qualquer caracter
	.*      :  aceita 0 ou mais caracteres diferentes de \n (guloso)
	.*?     :  aceita 0 ou mais caracteres diferentes de \n (não-guloso)

	regex -> skip : qualquer instância da expressão regular regex não é passada para o parser, sendo assim ignorada (usado em comentários, espaços em branco, ou (no caso deste exercício) diretivas de preprocessamento)


	no ANTLR alguns desses caracteres especiais podem ser utilizados nas regras da gramática também
	ex.:
		expr ('+'|'-') expr
	estabelece que os dois sinais têm a mesma precedência
		'(' (expr (',' expr)*)? ')'
	indica que dentro destes parênteses pode haver zero ou mais expressões separadas por vírgulas
}

regras da gramática {
	nome_da_regra
		: uma seqüência de regras que satisfazem esta
		| outra
		| e mais outra
		;

	NOME_DA_EXPRESSÃO_REGULAR : a_expressão_regular ;

	dentro de uma regra a primeira opção tem maior precedência (útil em expressões matemáticas)
}
*/
