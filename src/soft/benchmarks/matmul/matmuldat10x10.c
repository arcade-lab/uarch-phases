int row=ROWSIZE;
int col=COLSIZE;
int m1[10][10];
m1[0][0]=19;
m1[0][1]=88;
m1[0][2]=24;
m1[0][3]=59;
m1[0][4]=14;
m1[0][5]=65;
m1[0][6]=83;
m1[0][7]=50;
m1[0][8]=71;
m1[0][9]=9;
m1[1][0]=22;
m1[1][1]=18;
m1[1][2]=70;
m1[1][3]=6;
m1[1][4]=16;
m1[1][5]=89;
m1[1][6]=60;
m1[1][7]=64;
m1[1][8]=99;
m1[1][9]=43;
m1[2][0]=25;
m1[2][1]=22;
m1[2][2]=79;
m1[2][3]=5;
m1[2][4]=42;
m1[2][5]=59;
m1[2][6]=75;
m1[2][7]=95;
m1[2][8]=83;
m1[2][9]=72;
m1[3][0]=33;
m1[3][1]=98;
m1[3][2]=71;
m1[3][3]=37;
m1[3][4]=6;
m1[3][5]=52;
m1[3][6]=93;
m1[3][7]=76;
m1[3][8]=96;
m1[3][9]=98;
m1[4][0]=40;
m1[4][1]=12;
m1[4][2]=97;
m1[4][3]=42;
m1[4][4]=68;
m1[4][5]=98;
m1[4][6]=6;
m1[4][7]=1;
m1[4][8]=92;
m1[4][9]=35;
m1[5][0]=95;
m1[5][1]=50;
m1[5][2]=2;
m1[5][3]=69;
m1[5][4]=42;
m1[5][5]=27;
m1[5][6]=60;
m1[5][7]=8;
m1[5][8]=89;
m1[5][9]=75;
m1[6][0]=47;
m1[6][1]=62;
m1[6][2]=20;
m1[6][3]=3;
m1[6][4]=67;
m1[6][5]=31;
m1[6][6]=33;
m1[6][7]=86;
m1[6][8]=45;
m1[6][9]=92;
m1[7][0]=58;
m1[7][1]=12;
m1[7][2]=28;
m1[7][3]=35;
m1[7][4]=61;
m1[7][5]=64;
m1[7][6]=34;
m1[7][7]=3;
m1[7][8]=70;
m1[7][9]=76;
m1[8][0]=76;
m1[8][1]=4;
m1[8][2]=18;
m1[8][3]=86;
m1[8][4]=36;
m1[8][5]=68;
m1[8][6]=21;
m1[8][7]=50;
m1[8][8]=22;
m1[8][9]=51;
m1[9][0]=37;
m1[9][1]=24;
m1[9][2]=17;
m1[9][3]=40;
m1[9][4]=31;
m1[9][5]=53;
m1[9][6]=7;
m1[9][7]=21;
m1[9][8]=18;
m1[9][9]=55;
int m2[10][10];
m2[0][0]=80;
m2[0][1]=46;
m2[0][2]=7;
m2[0][3]=89;
m2[0][4]=72;
m2[0][5]=76;
m2[0][6]=98;
m2[0][7]=54;
m2[0][8]=95;
m2[0][9]=18;
m2[1][0]=12;
m2[1][1]=79;
m2[1][2]=9;
m2[1][3]=64;
m2[1][4]=28;
m2[1][5]=69;
m2[1][6]=78;
m2[1][7]=27;
m2[1][8]=39;
m2[1][9]=8;
m2[2][0]=20;
m2[2][1]=85;
m2[2][2]=38;
m2[2][3]=24;
m2[2][4]=26;
m2[2][5]=54;
m2[2][6]=51;
m2[2][7]=69;
m2[2][8]=12;
m2[2][9]=89;
m2[3][0]=57;
m2[3][1]=10;
m2[3][2]=8;
m2[3][3]=31;
m2[3][4]=71;
m2[3][5]=49;
m2[3][6]=96;
m2[3][7]=89;
m2[3][8]=77;
m2[3][9]=89;
m2[4][0]=13;
m2[4][1]=50;
m2[4][2]=61;
m2[4][3]=1;
m2[4][4]=62;
m2[4][5]=81;
m2[4][6]=30;
m2[4][7]=3;
m2[4][8]=46;
m2[4][9]=75;
m2[5][0]=32;
m2[5][1]=3;
m2[5][2]=18;
m2[5][3]=24;
m2[5][4]=83;
m2[5][5]=69;
m2[5][6]=21;
m2[5][7]=85;
m2[5][8]=66;
m2[5][9]=76;
m2[6][0]=42;
m2[6][1]=8;
m2[6][2]=43;
m2[6][3]=12;
m2[6][4]=8;
m2[6][5]=57;
m2[6][6]=4;
m2[6][7]=85;
m2[6][8]=87;
m2[6][9]=31;
m2[7][0]=30;
m2[7][1]=35;
m2[7][2]=11;
m2[7][3]=5;
m2[7][4]=24;
m2[7][5]=17;
m2[7][6]=59;
m2[7][7]=35;
m2[7][8]=43;
m2[7][9]=51;
m2[8][0]=93;
m2[8][1]=95;
m2[8][2]=44;
m2[8][3]=98;
m2[8][4]=53;
m2[8][5]=60;
m2[8][6]=18;
m2[8][7]=76;
m2[8][8]=49;
m2[8][9]=19;
m2[9][0]=53;
m2[9][1]=66;
m2[9][2]=44;
m2[9][3]=14;
m2[9][4]=27;
m2[9][5]=54;
m2[9][6]=36;
m2[9][7]=46;
m2[9][8]=78;
m2[9][9]=35;
int ans[10][10];
ans[0][0]=20747;
ans[0][1]=21104;
ans[0][2]=11972;
ans[0][3]=19632;
ans[0][4]=20778;
ans[0][5]=27649;
ans[0][6]=22283;
ans[0][7]=30491;
ans[0][8]=28554;
ans[0][9]=21210;
ans[1][0]=22700;
ans[1][1]=24474;
ans[1][2]=15134;
ans[1][3]=18472;
ans[1][4]=21137;
ans[1][5]=27195;
ans[1][6]=17401;
ans[1][7]=31493;
ans[1][8]=26881;
ans[1][9]=23778;
ans[2][0]=24098;
ans[2][1]=28492;
ans[2][2]=18129;
ans[2][3]=17659;
ans[2][4]=21549;
ans[2][5]=30160;
ans[2][6]=21165;
ans[2][7]=32301;
ans[2][8]=30685;
ans[2][9]=27003;
ans[3][0]=29395;
ans[3][1]=35113;
ans[3][2]=18780;
ans[3][3]=25590;
ans[3][4]=24583;
ans[3][5]=36636;
ans[3][6]=29435;
ans[3][7]=39427;
ans[3][8]=38073;
ans[3][9]=27405;
ans[4][0]=22391;
ans[4][1]=26280;
ans[4][2]=16179;
ans[4][3]=19961;
ans[4][4]=26963;
ans[4][5]=31203;
ans[4][6]=20932;
ans[4][7]=30596;
ans[4][8]=26065;
ans[4][9]=28945;
ans[5][0]=28595;
ans[5][1]=25526;
ans[5][2]=14675;
ans[5][3]=25064;
ans[5][4]=25450;
ans[5][5]=32370;
ans[5][6]=26777;
ans[5][7]=30774;
ans[5][8]=35801;
ans[5][9]=20215;
ans[6][0]=19965;
ans[6][1]=25854;
ans[6][2]=14709;
ans[6][3]=16059;
ans[6][4]=19777;
ans[6][5]=27654;
ans[6][6]=22739;
ans[6][7]=22162;
ans[6][8]=28432;
ans[6][9]=20254;
ans[7][0]=22236;
ans[7][1]=21631;
ans[7][2]=14650;
ans[7][3]=17631;
ans[7][4]=22925;
ans[7][5]=28113;
ans[7][6]=18891;
ans[7][7]=25937;
ans[7][8]=28484;
ans[7][9]=21383;
ans[8][0]=21165;
ans[8][1]=15580;
ans[8][2]=10025;
ans[8][3]=15158;
ans[8][4]=23945;
ans[8][5]=24967;
ans[8][6]=24708;
ans[8][7]=26549;
ans[8][8]=29391;
ans[8][9]=23928;
ans[9][0]=13480;
ans[9][1]=13283;
ans[9][2]=8030;
ans[9][3]=10503;
ans[9][4]=15938;
ans[9][5]=18320;
ans[9][6]=15819;
ans[9][7]=17205;
ans[9][8]=19343;
ans[9][9]=15839;
int res[10][10];
res[0][0]=0;
res[0][1]=0;
res[0][2]=0;
res[0][3]=0;
res[0][4]=0;
res[0][5]=0;
res[0][6]=0;
res[0][7]=0;
res[0][8]=0;
res[0][9]=0;
res[1][0]=0;
res[1][1]=0;
res[1][2]=0;
res[1][3]=0;
res[1][4]=0;
res[1][5]=0;
res[1][6]=0;
res[1][7]=0;
res[1][8]=0;
res[1][9]=0;
res[2][0]=0;
res[2][1]=0;
res[2][2]=0;
res[2][3]=0;
res[2][4]=0;
res[2][5]=0;
res[2][6]=0;
res[2][7]=0;
res[2][8]=0;
res[2][9]=0;
res[3][0]=0;
res[3][1]=0;
res[3][2]=0;
res[3][3]=0;
res[3][4]=0;
res[3][5]=0;
res[3][6]=0;
res[3][7]=0;
res[3][8]=0;
res[3][9]=0;
res[4][0]=0;
res[4][1]=0;
res[4][2]=0;
res[4][3]=0;
res[4][4]=0;
res[4][5]=0;
res[4][6]=0;
res[4][7]=0;
res[4][8]=0;
res[4][9]=0;
res[5][0]=0;
res[5][1]=0;
res[5][2]=0;
res[5][3]=0;
res[5][4]=0;
res[5][5]=0;
res[5][6]=0;
res[5][7]=0;
res[5][8]=0;
res[5][9]=0;
res[6][0]=0;
res[6][1]=0;
res[6][2]=0;
res[6][3]=0;
res[6][4]=0;
res[6][5]=0;
res[6][6]=0;
res[6][7]=0;
res[6][8]=0;
res[6][9]=0;
res[7][0]=0;
res[7][1]=0;
res[7][2]=0;
res[7][3]=0;
res[7][4]=0;
res[7][5]=0;
res[7][6]=0;
res[7][7]=0;
res[7][8]=0;
res[7][9]=0;
res[8][0]=0;
res[8][1]=0;
res[8][2]=0;
res[8][3]=0;
res[8][4]=0;
res[8][5]=0;
res[8][6]=0;
res[8][7]=0;
res[8][8]=0;
res[8][9]=0;
res[9][0]=0;
res[9][1]=0;
res[9][2]=0;
res[9][3]=0;
res[9][4]=0;
res[9][5]=0;
res[9][6]=0;
res[9][7]=0;
res[9][8]=0;
res[9][9]=0;