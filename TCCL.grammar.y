%namespace ASTBuilder
%partial
%parsertype TCCLParser
%visibility internal
%tokentype Token
%YYSTYPE AbstractNode


%start CompilationUnit

%token AND ASTERISK BANG BOOLEAN CLASS
%token COLON COMMA ELSE EQUALS HAT
%token IDENTIFIER IF INSTANCEOF INT INT_NUMBER
%token LBRACE LBRACKET LITERAL LPAREN MINUSOP
%token NEW NULL OP_EQ OP_GE OP_GT
%token OP_LAND OP_LE OP_LOR OP_LT OP_NE
%token PERCENT PERIOD PIPE PLUSOP PRIVATE
%token PUBLIC QUESTION RBRACE RBRACKET RETURN
%token RPAREN RSLASH SEMICOLON STATIC STRUCT
%token SUPER THIS TILDE VOID WHILE


%right EQUALS
%left  OP_LOR
%left  OP_LAND
%left  PIPE
%left  HAT
%left  AND
%left  OP_EQ, OP_NE
%left  OP_GT, OP_LT, OP_LE, OP_GE
%left  PLUSOP, MINUSOP
%left  ASTERISK, RSLASH, PERCENT
%left  UNARY 

%%

//CompilationUnit             :   ClassDeclaration                    {$$ = new Identifier("Not Implemented: ClassDeclaration");}
CompilationUnit             :   ClassDeclaration                    {$$ = new ClassDeclaration($1);}
                            |	MethodDeclarations                  {$$ = new CompilationUnit($1);} 
					        ;


MethodDeclarations	        :	MethodDeclaration					 { $$ = $1;  }
					        |	MethodDeclarations MethodDeclaration { $1.makeSibling($2); $$ = $1;}
					        ;

MethodDeclaration           :   Modifiers TypeSpecifier MethodSignature MethodBody          {$$ = new MethodDeclaration($1, $2, $3, $4); }
                            ;

MethodSignature             :   Identifier LPAREN ParameterList RPAREN                      { $$ = new MethodSignature($1, $3); }
                            |   Identifier LPAREN RPAREN                                    { $$ = new MethodSignature($1); }
                            ;

ParameterList               :   Parameter                                                   { $$ = new ParameterList($1); }
                            |   ParameterList COMMA Parameter                               { $1.adoptChildren($3); $$ = $1;}  
                            ;

Parameter                   :   TypeSpecifier Identifier                                    { $$ = new Parameter($1, $2); }
                            ;

MethodBody                  :   Block                                                       { $$ = new MethodBody($1); }
                            ;



//ClassDeclaration    :   Modifiers CLASS Identifier ClassBody                    {$$ = new ClassDeclaration($1, $3, $4);}
ClassDeclaration    :   Modifiers CLASS Identifier ClassBody                    {$$ = $1.makeSibling($3); $$ = $1.makeSibling($4);}
                    ;

Modifiers           :   PUBLIC                              { $$ = new Modifiers(ModifierType.PUBLIC); }
//Modifiers           :   PUBLIC                              { $$ = $1;}
                    |   PRIVATE                             { $$ = new Modifiers(ModifierType.PRIVATE);}
                    |   STATIC                              { $$ = new Modifiers(ModifierType.STATIC);}
//                  |   Modifiers PUBLIC                    { $$ = new Identifier("Not Implemented: Modifier List");}
                    
//                  |   Modifiers PUBLIC                    { $$ = new Modifiers(ModifierType.PUBLIC);}
                    |   Modifiers PUBLIC                    {$$ = $1.makeSibling(new Modifiers(ModifierType.PUBLIC)); $$ = $1;}          
                    
                    |   Modifiers PRIVATE                   {$$ = $1.makeSibling(new Modifiers(ModifierType.PRIVATE)); $$ = $1;}          
//                    |   Modifiers STATIC                     { $$ = $1.adoptChildren($2);}

                    |   Modifiers STATIC                     {$$ = $1.makeSibling(new Modifiers(ModifierType.STATIC)); $$ = $1;}          

//                    |   Modifiers STATIC                     { $$ = new Modifiers($1, ModifierType.STATIC);}
                    ;

ClassBody           :   LBRACE FieldDeclarations RBRACE         {$$= new ClassBody($2);}
                    |   LBRACE RBRACE                       
                    ;
                                                               
FieldDeclarations   :   FieldDeclaration                             {$$ = $1;}       
                    |   FieldDeclarations FieldDeclaration          {$$ = $1.makeSibling($2); $$ = $1;}
                    ;

FieldDeclaration    :   FieldVariableDeclaration SEMICOLON  
                    |   MethodDeclaration                   
                    |   ConstructorDeclaration                    
                    |   StaticInitializer                   
                    |   StructDeclaration                   
                    ;

//StructDeclaration   :   Modifiers STRUCT Identifier ClassBody   { $$ = new Identifier("Not Implemented: StructDeclaration");}
StructDeclaration   :   Modifiers STRUCT Identifier ClassBody   { $$ = new StructDeclaration($1,$3,$4);}
                    ;



FieldVariableDeclaration    :   Modifiers TypeSpecifier FieldVariableDeclarators            {$$ = new FieldVariableDeclaration($1, $2, $3); }
                            ;

TypeSpecifier               :   TypeName                                                    { $$ = $1; }
                            |   ArraySpecifier                                              
                            ;

TypeName                    :   PrimitiveType                                               { $$ = $1; }
                            |   QualifiedName                                               
                            ;

ArraySpecifier              :   TypeName LBRACKET RBRACKET                                  {}
                            ;
                            
PrimitiveType               :   BOOLEAN                                                     { $$ = new PrimitiveType(EnumPrimitiveType.BOOLEAN); }
                            |   INT                                                         { $$ = new PrimitiveType(EnumPrimitiveType.INT); }
                            |   VOID                                                        { $$ = new PrimitiveType(EnumPrimitiveType.VOID); }
                            ;

FieldVariableDeclarators    :   FieldVariableDeclaratorName                                 {$$ = $1;}
                            |   FieldVariableDeclarators COMMA FieldVariableDeclaratorName  { $$= $1.makeSibling($3); $$=$1;}
                            ;


FieldVariableDeclaratorName :   Identifier                                                  {$$ = $1;}
                            ;

//ConstructorDeclaration      :   Modifiers MethodSignature Block                             {$$= $1.makeSibling($2); $$= $1.makeSibling($3);}
ConstructorDeclaration      :   Modifiers MethodSignature Block                             {$$= new ConstructorDeclaration($1,$2,$3);}
                            ;

StaticInitializer           :   STATIC Block                                                {}
                            ;
        
/*
 * These can't be reorganized, because the order matters.
 * For example:  int i;  i = 5;  int j = i;
 */
//Block                       :   LBRACE LocalItems RBRACE                            { $$ = new Block($2); }
Block                       :   LBRACE LocalItems RBRACE                            { $$ = $2; }
                            |   LBRACE RBRACE                                       { $$ =  new Identifier("Not Implemented: Block"); }
                            ;
                           

//LocalItems                  :   LocalItem                                           { $$ = $1; }              
LocalItems                  :   LocalItem                                           { $$ = new LocalItems($1); } 
//                            |   LocalItems LocalItem                                { $$ = $1.adoptChildren($2); }
                            |   LocalItems LocalItem                                { $$ = new LocalItems($1, $2); }
                            ;
                            
//LocalItem                     :   LocalVariableDeclaration							{ $$ = new LocalItem($1); }       
LocalItem                     :   LocalVariableDeclaration                          { $$ = $1; }
//                              |   Statement                                         { $$ = new Statement($1);}
                                |   Statement                                         { $$ = $1 ;}
                              ;                                     

LocalVariableDeclaration			:   TypeSpecifier LocalVariableNames SEMICOLON    { $$ = new LocalVariableDeclaration ($1, $2); }
                                    |   StructDeclaration                                  
                                    ;

LocalVariableNames          :   Identifier                                
                            |   LocalVariableNames COMMA Identifier                 { $$ = new LocalVariableNames($1, $3); }
                            ;

                            
Statement                   :   EmptyStatement                                              
                            |   ExpressionStatement SEMICOLON                      { $$ = new Statement($1);}        
                            |   SelectionStatement                                         
                            |   IterationStatement                                          
                            |   ReturnStatement                                            
                            |   Block                                                    
                            ;

EmptyStatement              :   SEMICOLON                                                   
                            ;

ExpressionStatement         :   Expression                                          {$$ = $1; }          
                            ;

/*
 *  You will eventually have to address the shift/reduce error that
 *     occurs when the second IF-rule is uncommented.
 *
 */

SelectionStatement          :   IF LPAREN Expression RPAREN Statement ELSE Statement        
//                          |   IF LPAREN Expression RPAREN Statement
                            ;


IterationStatement          :   WHILE LPAREN Expression RPAREN Statement
                            ;

ReturnStatement             :   RETURN Expression SEMICOLON
                            |   RETURN            SEMICOLON
                            ;

ArgumentList                :   Expression
                            |   ArgumentList COMMA Expression
                            ;


// TODO
Expression                  :   QualifiedName EQUALS Expression     { $$ = new Expression($1, ExprKind.EQUALS, $3); }
   /* short-circuit OR  */  |   Expression OP_LOR Expression        { $$ = new Expression($1, ExprKind.OP_LOR, $3); }
   /* short-circuit AND */  |   Expression OP_LAND Expression       { $$ = new Expression($1, ExprKind.OP_LAND, $3); }
                            |   Expression PIPE Expression          { $$ = new Expression($1, ExprKind.PIPE, $3); }
                            |   Expression HAT Expression           { $$ = new Expression($1, ExprKind.HAT, $3); }
                            |   Expression AND Expression           { $$ = new Expression($1, ExprKind.AND, $3); }
                            |   Expression OP_EQ Expression         { $$ = new Expression($1, ExprKind.OP_EQ, $3); }
                            |   Expression OP_NE Expression         { $$ = new Expression($1, ExprKind.OP_NE, $3); }
                            |   Expression OP_GT Expression         { $$ = new Expression($1, ExprKind.OP_GT, $3); }
                            |   Expression OP_LT Expression         { $$ = new Expression($1, ExprKind.OP_LT, $3); }
                            |   Expression OP_LE Expression         { $$ = new Expression($1, ExprKind.OP_LE, $3); }
                            |   Expression OP_GE Expression         { $$ = new Expression($1, ExprKind.OP_GE, $3); }    
                            |   Expression PLUSOP Expression		{ $$ = new Expression($1, ExprKind.PLUSOP, $3); }
                            |   Expression MINUSOP Expression		{ $$ = new Expression($1, ExprKind.MINUSOP, $3); }
                            |   Expression ASTERISK Expression      { $$ = new Expression($1, ExprKind.ASTERISK, $3); }
                            |   Expression RSLASH Expression        { $$ = new Expression($1, ExprKind.RSLASH, $3); }
                            |   Expression PERCENT Expression   /* remainder */  { $$ = new Expression($1, ExprKind.PERCENT, $3); }
                            |   ArithmeticUnaryOperator Expression  %prec UNARY
                            |   PrimaryExpression               { $$ = $1; }
                            ;

ArithmeticUnaryOperator     :   PLUSOP                                          
                            |   MINUSOP
                            ;
                            
PrimaryExpression           :   QualifiedName                   { $$ = $1;}   
                            |   NotJustName                     { $$ = $1;}
                            ;

NotJustName                 :   SpecialName                     { $$ = $1;}
                            |   ComplexPrimary                  { $$ = $1;}
                            ;

ComplexPrimary              :   LPAREN Expression RPAREN        { $$ = $2;}
                            |   ComplexPrimaryNoParenthesis     { $$ = $1;}
                            ;

ComplexPrimaryNoParenthesis :   LITERAL                         { $$ = $1;}
                            |   Number                          { $$ = $1;}
                            |   FieldAccess                     { $$ = $1;}   
                            |   MethodCall                      { $$ = $1;}    
                            ;

FieldAccess                 :   NotJustName PERIOD Identifier   { $$ = new Identifier("Not Implemented: FieldAccess");}   
                            ;       
                            
MethodCall                  :   MethodReference LPAREN ArgumentList RPAREN      { $$ =  new MethodCall($1, $3); }
                            |   MethodReference LPAREN RPAREN                   { $$ = new MethodCall($1); }
                            ;

MethodReference             :   ComplexPrimaryNoParenthesis     
                            |   QualifiedName                   
                            |   SpecialName                    
                            ;

QualifiedName               :   Identifier                        { $$ = $1; }                         
                            |   QualifiedName PERIOD Identifier                            
                            ;
SpecialName                 :   THIS                            
                            |   NULL                            
                            ;

Identifier                  :   IDENTIFIER                      { $$ = $1; }
                            ;

Number                      :   INT_NUMBER                      { $$ = $1; }
                            ;

%%

