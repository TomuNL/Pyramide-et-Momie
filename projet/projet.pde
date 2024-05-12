int iposX = 1;
int iposY = -1;

int posX = iposX;
int posY = iposY;

int posXM = 1;
int posYM = 3;
int directionMomie = 0;     // 0 -> NORD   1 -> EST   2 -> SUD   3 -> OUEST

int dirX = 0;
int dirY = 1;
int dirZ = 0;
int odirX = 0;
int odirY = 1;
int WALLD = 1;
int niveauActuel;

int anim = 0;
boolean animT=false;
boolean animR=false;
boolean animRecule=false;
boolean fantome=false;

boolean inLab = true;

int LAB_SIZE = 21;
char labyrinthe [][][];

char sides [][][][];

PShape laby0;
PShape ceiling0;
PShape ceiling1;
PShape pyramide;
PShape sable;

PShape duneNord;
PShape duneEst;
PShape duneSud;
PShape duneOuest;

PShape momie;

PImage  texture0;
PImage textureExterieur;
PImage textureSable;

void setup() {
  pixelDensity(2);
  randomSeed(2);
  texture0 = loadImage("NormalMap.jpg");
  textureExterieur = loadImage("stonewallA.jpg");
  textureSable = loadImage("sable.jpg");
  
  size(1000, 1000, P3D);
  labyrinthe = new char[2][LAB_SIZE][LAB_SIZE];
  sides = new char[2][LAB_SIZE][LAB_SIZE][4];
  //int todig = 0;
  for (int l = 0; l < 2; l++){
    for (int j=0; j<LAB_SIZE; j++) {
      for (int i=0; i<LAB_SIZE; i++) {
        sides[l][j][i][0] = 0;
        sides[l][j][i][1] = 0;
        sides[l][j][i][2] = 0;
        sides[l][j][i][3] = 0;
        if (j%2==1 && i%2==1) {
          labyrinthe[l][j][i] = '.';
          //todig ++;
        } else
          labyrinthe[l][j][i] = '#';
      }
    }
  }

 
  buildLaby(labyrinthe, LAB_SIZE, 0);
  buildLaby(labyrinthe, LAB_SIZE-2, 1);

  /*int gx = 1;
  int gy = 1;
  while (todig>0 ) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4)); // selon un tirage aleatoire
    if      (alea==0 && gx>1)          gx -= 2; // le fantome va a gauche
    else if (alea==1 && gy>1)          gy -= 2; // le fantome va en haut
    else if (alea==2 && gx<LAB_SIZE-2) gx += 2; // .. va a droite
    else if (alea==3 && gy<LAB_SIZE-2) gy += 2; // .. va en bas

    if (labyrinthe[gy][gx] == '.') {
      todig--;
      labyrinthe[gy][gx] = ' ';
      labyrinthe[(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }*/

  labyrinthe[0][0][1] = ' '; // entree
  // sortie     (17, 14)

  for (int l = 0; l < 2; l++){
    for (int j=1; j<LAB_SIZE-1 - 2*l; j++) {
      for (int i=1; i<LAB_SIZE-1 - 2*l; i++) {
        if (labyrinthe[l][j][i]==' ') {
          if (labyrinthe[l][j-1][i]=='#' && labyrinthe[l][j+1][i]==' ' &&
            labyrinthe[l][j][i-1]=='#' && labyrinthe[l][j][i+1]=='#')
            sides[l][j-1][i][0] = 1;// c'est un bout de couloir vers le haut
          if (labyrinthe[l][j-1][i]==' ' && labyrinthe[l][j+1][i]=='#' &&
            labyrinthe[l][j][i-1]=='#' && labyrinthe[l][j][i+1]=='#')
            sides[l][j+1][i][3] = 1;// c'est un bout de couloir vers le bas
          if (labyrinthe[l][j-1][i]=='#' && labyrinthe[l][j+1][i]=='#' &&
            labyrinthe[l][j][i-1]==' ' && labyrinthe[l][j][i+1]=='#')
            sides[l][j][i+1][1] = 1;// c'est un bout de couloir vers la droite
          if (labyrinthe[l][j-1][i]=='#' && labyrinthe[l][j+1][i]=='#' &&
            labyrinthe[l][j][i-1]=='#' && labyrinthe[l][j][i+1]==' ')
            sides[l][j][i-1][2] = 1;// c'est un bout de couloir vers la gauche
        }
      }
    }
  }

  // un affichage texte pour vous aider a visualiser le labyrinthe en 2D
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      print(labyrinthe[1][j][i]);
    }
    println("");
  }
 
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;
  
  niveauActuel = 0;

  ceiling0 = createShape();
  ceiling1 = createShape();
 
  ceiling1.beginShape(QUADS);
  ceiling0.beginShape(QUADS);
 
  laby0 = createShape();
  laby0.beginShape(QUADS);
  laby0.texture(texture0);
 
  pyramide = createShape();
  pyramide.beginShape(QUADS);
  pyramide.texture(textureExterieur);
  
  sable = createShape();
  sable.beginShape(QUADS);
  sable.texture(textureSable);
 
 
  laby0.noStroke();
  //laby0.stroke(255, 32);
  //laby0.strokeWeight(0.5);
   for(int lev = 0; lev < 2; lev++){
    for (int j=0; j<LAB_SIZE; j++) {
      for (int i=0; i<LAB_SIZE; i++) {
        if (lev == 1 && (j >= 19 || i >= 19)) continue;
        if (labyrinthe[lev][j][i]=='#'){
          laby0.fill(i*25, j*25, 255-i*10+j*10);
          if (j==0 || labyrinthe[lev][j-1][i]==' ') {
            laby0.normal(0, -1, 0);
            if (j == 0) tint(223,175,44);
            if (lev == 1 && j == 0){
              if (i == 0) continue;
              for (int k=0; k<WALLD; k++)
              for (int l=-WALLD; l<WALLD; l++) {
                
                if (j==LAB_SIZE-1) laby0.tint(223,175,44);
                
                //    MUR DU BAS
                
                laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                
              }
              laby0.noTint();
            } else {
                for (int k=0; k<WALLD; k++)
                for (int l=-WALLD; l<WALLD; l++) {
                  
                  //MUR DU HAUT
               
                  if (j==0) laby0.tint(223,175,44);   
                  
                  
                  //float d1 = 15*(noise(0.3*(i*WALLD+(k+0)), 0.3*(j*WALLD), 0.3*(l+0))-0.5);
                  //if (k==0)  d1=0;
                  //if (l==-WALLD) d1=-2*abs(d1);
                  laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD + 100*lev, k/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
                  
                  //float d2 =15*(noise(0.3*(i*WALLD+(k+1)), 0.3*(j*WALLD), 0.3*(l+0))-0.5);
                  //if (k+1==WALLD ) d2=0;
                  //if (l==-WALLD) d2=-2*abs(d2);
                  laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
                  
                  //float d3 = 15*(noise(0.3*(i*WALLD+(k+1)), 0.3*(j*WALLD), 0.3*(l+1))-0.5);
                  //if (k+1==WALLD ||l+1==WALLD) d3=0;
                  laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                  
                  //float d4 = 15*(noise(0.3*(i*WALLD+(k+0)), 0.3*(j*WALLD), 0.3*(l+1))-0.5);
                  //if (k==0 ||l+1==WALLD) d4=0;
                  laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD + 100*lev, k/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);               
                }
              }
              laby0.noTint();
          }  
          
          if (j==LAB_SIZE-1 || labyrinthe[lev][j+1][i]==' ') {
            if (j == LAB_SIZE-1) laby0.tint(223,175,44);
            laby0.normal(0, 1, 0);
            for (int k=0; k<WALLD; k++)
              for (int l=-WALLD; l<WALLD; l++) {
                
                if (j==LAB_SIZE-1) laby0.tint(223,175,44);
                
                //    MUR DU BAS
                
                laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                
              }
              laby0.noTint();
          }
  
          if (i==0 || labyrinthe[lev][j][i-1]==' ') {
            if (lev == 1 && i == 0){
              for (int k=0; k<WALLD; k++)
              for (int l=-WALLD; l<WALLD; l++) {
                
                if (i==LAB_SIZE-1) laby0.tint(223,175,44);
                
                // MUR DE DROITE
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+0)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+0)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+1)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+1)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                
              }
            } else {
              laby0.normal(-1, 0, 0);
              for (int k=0; k<WALLD; k++)
                for (int l=-WALLD; l<WALLD; l++) {
                  // MUR DE GAUCHE
                  
                  if (i == 0) laby0.tint(223,175,44);
                  
                  laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+1)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                  laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+1)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                  laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+0)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                  laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+0)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                  
                }
                laby0.noTint();
            }
          }
  
          if (i==LAB_SIZE-1 || labyrinthe[lev][j][i+1]==' ') {
            laby0.normal(1, 0, 0);
            for (int k=0; k<WALLD; k++)
              for (int l=-WALLD; l<WALLD; l++) {
                
                if (i==LAB_SIZE-1) laby0.tint(223,175,44);
                
                // MUR DE DROITE
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+0)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+0)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+1)*50/WALLD + 100*lev, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+1)*50/WALLD + 100*lev, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                
              }
              laby0.noTint();
          }
          ceiling1.fill(32, 255, 0);
          ceiling1.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50 + 100*lev);
          ceiling1.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50 + 100*lev);
          ceiling1.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50 + 100*lev);
          ceiling1.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50 + 100*lev);        
        }          else {
          // PORTE D'ENTREE
          if (j == 0 && i == 1){
            for (int k=0; k<WALLD; k++){
              for (int l=-WALLD; l<WALLD; l++) {
                laby0.tint(0, 245);
                laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD, k/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD, k/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
                laby0.noTint();
              }
            }             
          }
          
          if (lev == 0 && j == 17 && i == 14){
            laby0.fill(192); // ground
            laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50 + 100*lev, 0, 0);
            laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50 + 100*lev, 0, 1);
            laby0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50 + 100*lev, 1, 1);
            laby0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50 + 100*lev, 1, 0);
          } else if (lev == 1 && j == 17 && i == 14){
            ceiling0.fill(32); // top of walls
            ceiling0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50 + 100*lev);
            ceiling0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50 + 100*lev);
            ceiling0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50 + 100*lev);
            ceiling0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50 + 100*lev);
            ceiling0.noTint();
          } else {
            laby0.fill(192); // ground
            laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50 + 100*lev, 0, 0);
            laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50 + 100*lev, 0, 1);
            laby0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50 + 100*lev, 1, 1);
            laby0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50 + 100*lev, 1, 0);
            
            ceiling0.fill(32); // top of walls
            ceiling0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50 + 100*lev);
            ceiling0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50 + 100*lev);
            ceiling0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50 + 100*lev);
            ceiling0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50 + 100*lev);
            
          }
        }
      }
    }
   }
 
  pyramide.noTint();
  pyramide.noStroke();
 
  for (int h = 0; h <= 11; h++){
    for (int i = 0; i < LAB_SIZE - h*2 ; i++){ 
      if (h == 9) {
        pyramide.textureMode(NORMAL);
        pyramide.tint(255);
      }
        //MUR ARRIERE PYRAMIDE
        pyramide.vertex(i*wallW-wallW/2 + wallW*h, -wallH-wallH/2 + (LAB_SIZE+2) * wallH - wallH*h, -50 + 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(i*wallW+wallW/2 + wallW*h, -wallH-wallH/2 + (LAB_SIZE+2) * wallH - wallH*h, -50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(i*wallW+wallH/2 + wallW*h, -wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h, 50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(i*wallW-wallH/2 + wallW*h, -wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h, 50 + 100*h, 0, (0.5+(1)/2.0/WALLD)*textureExterieur.height); 
        
        //MUR DROIT PYRAMIDE
        pyramide.vertex(-wallH-wallH/2 + wallH*h, i*wallW-wallW/2 + wallW*h, -50 + 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(-wallH-wallH/2 + wallH*h, i*wallW+wallW/2 + wallW*h, -50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + wallH*h, i*wallW+wallW/2 + wallW*h, 50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + wallH*h, i*wallW-wallW/2 + wallW*h, 50 + 100*h, 0, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        
        //MUR GAUCHE PYRAMIDE
        pyramide.vertex(-wallH-wallH/2 + (LAB_SIZE+2) * wallH - wallH*h, i*wallW-wallW/2 + wallW*h, -50 + 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(-wallH-wallH/2 + (LAB_SIZE+2) * wallH - wallH*h, i*wallW+wallW/2 + wallW*h, -50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h, i*wallW+wallH/2 + wallW*h, 50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h,i*wallW-wallH/2 + wallW*h, 50 + 100*h, 0, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
         
        
        if (i==1 && h == 0) continue;
        //MUR AVANT PYRAMIDE
        pyramide.vertex(i*wallW-wallW/2 + wallW*h, -wallH-wallH/2 + wallH*h, -50 + 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(i*wallW+wallW/2+ wallW*h, -wallH-wallH/2 + wallH*h, -50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(i*wallW+wallH/2+ wallW*h, -wallH+wallH/2 + wallH*h, 50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(i*wallW-wallH/2+ wallW*h, -wallH+wallH/2 + wallH*h, 50 + 100*h, 0, (0.5+(1)/2.0/WALLD)*textureExterieur.height);    
    }
  }
  
  pyramide.textureMode(IMAGE);
  for (int h = 0; h <= 10; h++){
        //COIN ARRIERE DROIT PYRAMIDE
        pyramide.vertex(-wallH-wallH/2 + wallW*h, -wallH+wallH/2 + (LAB_SIZE) * wallH  - wallH*h, -50+ 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(-wallW+wallH/2 + wallW*h, -wallH+wallH/2 + (LAB_SIZE) * wallH  - wallH*h, 50+ 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallW+wallW/2 + wallW*h, -wallH-wallH/2 + (LAB_SIZE+2) * wallH  - wallH*h, -50+ 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallW+wallW/2 + wallW*h, -wallH-wallH/2 + (LAB_SIZE+2) * wallH  - wallH*h, -50+ 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        
        
        //COIN AVANT DROIT PYRAMIDE
        pyramide.vertex(-wallH+wallH/2 + wallH*h, -wallW-wallW/2 + wallW*h, -50 + 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(-wallH+wallH/2 + wallH*h, -wallW+wallW/2 + wallW*h, 50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH-wallH/2 + wallH*h, -wallW+wallW/2 + wallW*h, -50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH-wallH/2 + wallH*h, -wallW+wallW/2 + wallW*h, -50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);      
        
        //COIN AVANT GAUCHE PYRAMIDE
        pyramide.vertex(-wallH-wallH/2 + (LAB_SIZE+1) * wallH - wallH*h, -wallW-wallW/2 + wallW*h, -50 + 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(-wallH-wallH/2 + (LAB_SIZE+2) * wallH - wallH*h, -wallW+wallW/2 + wallW*h, -50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h, -wallW+wallH/2 + wallW*h, 50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h, -wallW+wallH/2 + wallW*h, 50 + 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        
        //MUR AVANT PYRAMIDE
        pyramide.vertex(-wallH-wallH/2 + (LAB_SIZE+2) * wallH - wallH*h, -wallH+wallH/2 + (LAB_SIZE) * wallH  - wallH*h, -50+ 100*h, 0, (0.5/2.0/WALLD)*texture0.height);
        pyramide.vertex(-wallH-wallH/2 + (LAB_SIZE+1) * wallH - wallH*h, -wallH+wallH/2 + (LAB_SIZE) * wallH  - wallH*h, 50+ 100*h, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h, -wallH-wallH/2 + (LAB_SIZE+2) * wallH  - wallH*h, -50+ 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
        pyramide.vertex(-wallH+wallH/2 + (LAB_SIZE) * wallH - wallH*h, -wallH-wallH/2 + (LAB_SIZE+2) * wallH  - wallH*h, -50+ 100*h, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
  }
  
  //POINTE de la Pyramide
  
  
  
  
  
  
  //ENTREE COTE DROIT
  pyramide.vertex(-wallW+wallW/2+ wallH, -wallH-wallH/2, -50, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
  pyramide.vertex(-wallW+wallW/2+ wallH, -wallH-wallH/2, -50, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
  pyramide.vertex(-wallW+wallH/2+ wallH, -wallH+wallH/2, -50, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
  pyramide.vertex(wallH/2, -wallH+wallH/2, -50+100, 0, (0.5+(1)/2.0/WALLD)*textureExterieur.height); 
  
  //ENTREE COTE GAUCHE
  pyramide.vertex(wallW+wallW/2, -wallH-wallH/2, -50, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
  pyramide.vertex(wallW+wallW/2, -wallH-wallH/2, -50, 1/(float)WALLD*textureExterieur.width, (0.5/2.0/WALLD)*textureExterieur.height);
  pyramide.vertex(wallW+wallH/2, -wallH+wallH/2, -50, 1/(float)WALLD*textureExterieur.width, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
  pyramide.vertex(wallW+wallH/2, -wallH+wallH/2, -50+100, 0, (0.5+(1)/2.0/WALLD)*textureExterieur.height);
  
  sable.noTint();
  sable.noStroke();

  for (int h = -LAB_SIZE*3; h <= LAB_SIZE*3; h++){
      for (int i = -LAB_SIZE*3; i <= LAB_SIZE*3; i++){ 
        if(!(i>=1 && i<=LAB_SIZE-1) && (i<=LAB_SIZE*2) || !(h>=1 && h<=LAB_SIZE-1) && (h<=LAB_SIZE*2)){
        //SABLE 
          sable.vertex(i*wallW-wallW/2, -wallH-wallH/2+ wallH*h, -50+noise(h,i)*10, 0, (0.5/2.0/WALLD)*texture0.height);
          sable.vertex(i*wallW+wallW/2, -wallH-wallH/2+ wallH*h, -50+noise(h,i+1)*10, 1/(float)WALLD*textureSable.width, (0.5/2.0/WALLD)*textureSable.height);
          sable.vertex(i*wallW+wallH/2, -wallH+wallH/2+ wallH*h, -50+noise(h+1,i+1)*10, 1/(float)WALLD*textureSable.width, (0.5+(1)/2.0/WALLD)*textureSable.height);
          sable.vertex(i*wallW-wallH/2, -wallH+wallH/2+ wallH*h, -50+noise(h+1,i)*10, 0, (0.5+(1)/2.0/WALLD)*textureSable.height);  
        }
        
        else if(i>LAB_SIZE*2 || h>LAB_SIZE*2){
          sable.vertex(i*wallW-wallW/2, -wallH-wallH/2+ wallH*h, -50+noise(h,i)*10, 0, (0.5/2.0/WALLD)*texture0.height);
          sable.vertex(i*wallW+wallW/2, -wallH-wallH/2+ wallH*h, -50+noise(h,i+1)*10, 1/(float)WALLD*textureSable.width, (0.5/2.0/WALLD)*textureSable.height);
          sable.vertex(i*wallW+wallH/2, -wallH+wallH/2+ wallH*h, -50+noise(h+1,i+1)*10, 1/(float)WALLD*textureSable.width, (0.5+(1)/2.0/WALLD)*textureSable.height);
          sable.vertex(i*wallW-wallH/2, -wallH+wallH/2+ wallH*h, -50+noise(h+1,i)*10, 0, (0.5+(1)/2.0/WALLD)*textureSable.height);
        }
      }
  }
  
  
  // DUNE DE SABLE
  int cols = 20;
  int rows = LAB_SIZE*6-1;
  float terrain [][];
  terrain = new float[cols][rows];
  int scl = 50;
  
  float yoff = 0.1;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -100, 100 + 30*x);
      xoff += 0.2;
    }
    yoff += 0.2;
  }
  
  duneEst = createShape();
  duneEst.translate(3*LAB_SIZE*wallW, -3*LAB_SIZE*wallW, -50);
  duneEst.beginShape(TRIANGLE_STRIP);
  duneEst.fill(204,167,103);
  duneEst.noStroke();
  for (int i = 0; i < 2; i++){
    for (int y = 0; y < rows-1; y++) {
      for (int x = 0; x < cols; x++) {
        if (x == 0 || x == cols-1){
          duneEst.vertex(x * scl,y * scl, map(terrain[x][y], -100, 300, -100, -50));
          duneEst.vertex(x * scl,(y+1) * scl, map(terrain[x][y], -100, 300, -100, -50));
        }else {
          duneEst.vertex(x * scl,y * scl, terrain[x][y]);
          duneEst.vertex(x * scl,(y+1) * scl, terrain[x][y+1]);
        }
      }
    }
  }
  
  duneNord = createShape();
  duneNord.translate(2*LAB_SIZE*wallW, -4*LAB_SIZE*wallW + 1350, -50);
  duneNord.beginShape(TRIANGLE_STRIP);
  duneNord.fill(204,167,103);
  duneNord.noStroke();
  duneNord.rotate(-PI/2);
  for (int y = 0; y < rows-1; y++) {
    for (int x = 0; x < cols; x++) {
      if (x == 0 || x == cols-1){
        duneNord.vertex(x * scl, y * scl, map(terrain[x][y], -100, 300, -100, -50));
        duneNord.vertex(x * scl, (y+1) * scl, map(terrain[x][y], -100, 300, -100, -50));
      }else {
        duneNord.vertex(x * scl, y * scl, terrain[x][y]);
        duneNord.vertex(x * scl, (y+1) * scl, terrain[x][y+1]);
      }
    }
  }
  
  duneOuest = createShape();
  duneOuest.translate(3*LAB_SIZE*wallW - 1350, -3*LAB_SIZE*wallW, -50);
  duneOuest.beginShape(TRIANGLE_STRIP);
  duneOuest.fill(204,167,103);
  duneOuest.noStroke();
  duneOuest.rotate(PI);
  for (int y = 0; y < rows-1; y++) {
    for (int x = 0; x < cols; x++) {
      if (x == 0 || x == cols-1){
        duneOuest.vertex(x * scl, y * scl, map(terrain[x][y], -100, 300, -100, -50));
        duneOuest.vertex(x * scl, (y+1) * scl, map(terrain[x][y], -100, 300, -100, -50));
      }else {
        duneOuest.vertex(x * scl, y * scl, terrain[x][y]);
        duneOuest.vertex(x * scl, (y+1) * scl, terrain[x][y+1]);
      }
    }
  }
  
  duneSud = createShape();
  duneSud.translate(3*LAB_SIZE*wallW-200, -5*LAB_SIZE*wallW + 1350, -50);
  duneSud.beginShape(TRIANGLE_STRIP);
  duneSud.fill(204,167,103);
  duneSud.noStroke();
  duneSud.rotate(PI/2);
  for (int y = 0; y < rows-1; y++) {
    for (int x = 0; x < cols; x++) {
      if (x == 0 || x == cols-1){
        duneSud.vertex(x * scl, y * scl, map(terrain[x][y], -100, 300, -100, -50));
        duneSud.vertex(x * scl, (y+1) * scl, map(terrain[x][y], -100, 300, -100, -50));
      }else {
        duneSud.vertex(x * scl, y * scl, terrain[x][y]);
        duneSud.vertex(x * scl, (y+1) * scl, terrain[x][y+1]);
      }
    }
  }
  
  momie = createShape(GROUP);
  createMomieShape();
  
  duneSud.endShape();
  duneOuest.endShape();
  duneNord.endShape();
  duneEst.endShape();
  sable.endShape();
  pyramide.endShape();
  laby0.endShape();
  ceiling0.endShape();
  ceiling1.endShape();
  
  momie.rotate(PI);      //demi tour
    momie.translate(width/LAB_SIZE * posXM*2, height/LAB_SIZE * posYM*2);
  directionMomie=2;
  
}

/*
    momie.rotate(PI);      //demi tour
    momie.translate(width/LAB_SIZE * posXM*2, height/LAB_SIZE * posYM*2);
    
    momie.rotate(PI/2);    //tourner a droite
    momie.translate(width/LAB_SIZE * (posYM + posXM), height/LAB_SIZE * (posYM - posXM));
    
    momie.rotate(-PI/2);   //tourner a gauche
    momie.translate(-width/LAB_SIZE * (posYM - posXM), height/LAB_SIZE * (posYM + posXM));


*/
void draw() {
  
  background(119, 181, 254);
  sphereDetail(6);
  if (anim>0) anim--;

  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;
  
  perspective();
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);
  
  for (int j=0; j<LAB_SIZE - 2*niveauActuel; j++) {
    for (int i=0; i<LAB_SIZE - 2*niveauActuel; i++) {
      if((posX>=0 && posX <= LAB_SIZE) && (posY>=-1 && posY <= LAB_SIZE)){
        if (labyrinthe[niveauActuel][j][i]=='#' || (j == 17 && i == 14 || (j==posYM && i == posXM))) {
          if (j==posYM && i == posXM){
            pushMatrix();
            noStroke();
            fill(150, 150, 50);
            translate(50+i*wallW/8, 50+j*wallH/8, 50);
            sphere(3);
            popMatrix();
            stroke(0);
          } else{
            fill(i*25, j*25, 255-i*10+j*10);
            if (j == 17 && i == 14) fill(128,255,128);
            pushMatrix();
            translate(50+i*wallW/8, 50+j*wallH/8, 50);
            box(wallW/10, wallH/10, 5);
            popMatrix();
          }
        }
      } 
    }
  }
  
  if((posX>=0 && posX <= LAB_SIZE) && (posY>=-1 && posY <= LAB_SIZE) ){
    pushMatrix();
    fill(0, 255, 0);
    noStroke();
    translate(50+posX*wallW/8, 50+posY*wallH/8, 50);
    sphere(3);
    popMatrix();
  }
  
  stroke(0);
  if (inLab) {
    perspective(2*PI/3, float(width)/float(height), 1, 10000);
    if (animT){
      camera((posX-dirX*anim/20.0)*wallW,      (posY-dirY*anim/20.0)*wallH,      -15+2*sin(anim*PI/5.0) + 100*dirZ,
             (posX-dirX*anim/20.0+dirX)*wallW, (posY-dirY*anim/20.0+dirY)*wallH, -15+4*sin(anim*PI/5.0) + 100*dirZ, 0, 0, -1);
             /*camera((posX-dirX*anim/20.0)*wallW, (posY-dirY*anim/20.0)*wallH, -15+6*sin(anim*PI/20.0), (posX+dirX-dirX*anim/20.0)*wallW, (posY+dirY-dirY*anim/20.0)*wallH, -15+10*sin(anim*PI/20.0), 0, 0, -1);*/
           }
    else if (animR)
      camera(posX*wallW, posY*wallH, -15 + 100*dirZ,
            (posX+(odirX*anim+dirX*(20-anim))/20.0)*wallW, (posY+(odirY*anim+dirY*(20-anim))/20.0)*wallH, -15-5*sin(anim*PI/20.0) + 100*dirZ, 0, 0, -1);
    else {
      camera(posX*wallW, posY*wallH, -15 + 100*dirZ,
             (posX+dirX)*wallW, (posY+dirY)*wallH, -15 + 100*dirZ, 0, 0, -1);
    }
    

    if (posX>=0 && posX<LAB_SIZE && posY>=0 && posY+dirY<LAB_SIZE && dirZ <=1) lightFalloff(1.0, 0.02, 0.0001);
      pointLight(255, 255, 255, posX*wallW, posY*wallH, 15);
  } else{
    lightFalloff(0.0, 0.05, 0.0001);
    pointLight(255, 255, 255,width/2, height/2, 300 * LAB_SIZE);
  }

  noStroke();
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      pushMatrix();
      translate(i*wallW, j*wallH, 0);
      if (labyrinthe[niveauActuel][j][i]=='#') {
        beginShape(QUADS);
        if (sides[niveauActuel][j][i][3]==1) {
          pushMatrix();
          translate(0, -wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }

        if (sides[niveauActuel][j][i][0]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
         if (sides[niveauActuel][j][i][1]==1) {
          pushMatrix();
          translate(-wallW/2, 0, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
        if (sides[niveauActuel][j][i][2]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
      }
      popMatrix();
    }
  }
  
  // MOUVEMENT DE LA MOMIE
  if(frameCount %25 == 0){
    boolean mouv = true;   //SI IL Y A RIEN DEVANT ELLE, ELLE AVANCE
    if (posXM > 0 && posXM < LAB_SIZE-1 && posYM >= 0 && posYM < LAB_SIZE -1){
        if (posYM == 0) { // DEMI TOUR QUAND LA MOMIE EST EN FACE DE LA SORTIE DE LA PYRAMIDE
          momie.rotate(PI);   
          momie.translate(width/LAB_SIZE * posXM*2, height/LAB_SIZE * posYM*2);
          if (directionMomie <=1) directionMomie+=2;
          else if (directionMomie == 2) directionMomie = 0;
          else directionMomie = 1;
          
          momie.translate(0, height/LAB_SIZE);
          posYM += 1;
          mouv = false;
          
        }
        else if (directionMomie == 0 && labyrinthe[niveauActuel][posYM-1][posXM] != '#'){
          momie.translate(0, -height/LAB_SIZE);
          posYM -= 1;
          mouv = false;
        } else if (directionMomie == 1 && labyrinthe[niveauActuel][posYM][posXM+1] != '#'){
          momie.translate(width/LAB_SIZE, 0);
          posXM += 1;
          mouv = false;
        } else if (directionMomie == 2 && labyrinthe[niveauActuel][posYM+1][posXM] != '#'){ 
          momie.translate(0, height/LAB_SIZE);
          posYM += 1;
          mouv = false;
        } else if(directionMomie == 3 && labyrinthe[niveauActuel][posYM][posXM-1] != '#'){          
          momie.translate(-width/LAB_SIZE, 0);
          posXM -= 1;
          mouv = false;
        }
      } 
      if(mouv) {  //SINON ELLE CHANGE DE DIRECTION
        int r = int(random(3));

        if (r==0){   // TOURNER A DROITE
          momie.rotate(PI/2);
          momie.translate(width/LAB_SIZE * (posYM + posXM), height/LAB_SIZE * (posYM - posXM));
          if (directionMomie < 3)
            directionMomie++;
          else directionMomie=0;
        }
        
        else if (r==1) { // DEMI TOUR
          momie.rotate(PI);   
          momie.translate(width/LAB_SIZE * posXM*2, height/LAB_SIZE * posYM*2);
          if (directionMomie <=1) directionMomie+=2;
          else if (directionMomie == 2) directionMomie = 0;
          else directionMomie = 1;     
        }
        
        else {          //TOURNER A GAUCHE
          momie.rotate(-PI/2);   
          momie.translate(-width/LAB_SIZE * (posYM - posXM), height/LAB_SIZE * (posYM + posXM));
        
          if (directionMomie > 0) directionMomie--;
          else directionMomie = 3;
        }
      }
      //println(directionMomie + "\t" + posX + ", " + posY + "   " + posXM + ", " + posYM);
  }
  
  shape(duneSud, 0, 0); 
  shape(duneOuest, 0, 0); 
  shape(duneNord, 0, 0); 
  shape(duneEst, 0, 0);
  shape(laby0, 0, 0);
  shape(pyramide, 0, 0);
  shape(sable, 0, 0);
  shape(momie, 0, 0);
  if (inLab)
    shape(ceiling0, 0, 0);
  else
    shape(ceiling1, 0, 0);
}

void keyPressed() {

  if (key=='l') inLab = !inLab;

  if (anim==0 && keyCode==UP) { 
     if(fantome) {
          posX+=dirX;
          posY+=dirY;
          anim=20;
          animT = true;
          animR = false;  
    } else if (posX+dirX>=0 && posX+dirX<LAB_SIZE && posY+dirY>=0 && posY+dirY<LAB_SIZE) {
      if (labyrinthe[niveauActuel][posY+dirY][posX+dirX]!='#' || fantome){
        posX+=dirX;
        posY+=dirY;
        anim=20;
        animT = true;
        animR = false;
      }
    } else if ((posX+dirX < -1 || posX+dirX > LAB_SIZE || posY+dirY < -1 || posY+dirY > LAB_SIZE) || (posX+dirX == 1 || posY+dirY == -2)){
        if (posX+dirX < LAB_SIZE*2 && posX+dirX > -LAB_SIZE  && posY+dirY > -LAB_SIZE && posY+dirY < 2*LAB_SIZE){  
          posX+=dirX;
          posY+=dirY;
          anim=20;
          animT = true;
          animR = false;
        }
    }
     
  }
  if (anim==0 && keyCode==DOWN) {
    if (fantome){
          posX-=dirX;
          posY-=dirY;
    } else if (posX-dirX>=0 && posX-dirX<LAB_SIZE && posY-dirY>=0 && posY-dirY<LAB_SIZE) {
      if (labyrinthe[niveauActuel][posY-dirY][posX-dirX]!='#'){
        posX-=dirX;
        posY-=dirY;
      }
    } else if ( (posX-dirX < -1 || posX-dirX > LAB_SIZE || posY-dirY < -1 || posY-dirY > LAB_SIZE) || (posX-dirX == 1 || posY+dirY == -2)){
        if (posX-dirX < LAB_SIZE*2 && posX-dirX > -LAB_SIZE  && posY-dirY > -LAB_SIZE && posY-dirY < 2*LAB_SIZE){  
          posX-=dirX;
          posY-=dirY;
        }
    }
  }
  
  if (anim==0 && keyCode==LEFT) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    int tmp = dirX;
    dirX=dirY;
    dirY=-tmp;
    animT = false;
    animR = true;
  }
  if (anim==0 && keyCode==RIGHT) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    animT = false;
    animR = true;
    int tmp = dirX;
    dirX=-dirY;
    dirY=tmp;
  }
  
  if (anim==0 && keyCode==32){ // ESPACE
    if ( /*(posX < -1 || posX > LAB_SIZE || posY < -1 || posY > LAB_SIZE) ||*/ (posX ==14 && posY == 17) && dirZ == 0){
      if (posX ==14 && posY == 17){
        niveauActuel++;
        println("Vous passez au niveau 1");
        momie.translate(0,0,100);
      }
      dirZ+=1;
    }
  }
  
  if (anim==0 && keyCode==CONTROL){
    if ( (posX < -1 || posX > LAB_SIZE || posY < -1 || posY > LAB_SIZE) || (posX ==14 && posY == 17) && dirZ == 1){
      if (posX ==14 && posY == 17){
        niveauActuel--;
        println("Vous passez au niveau 0");
        momie.translate(0,0,-100);
      }
      dirZ-=1;
    }
  }
  
  if (anim==0 && keyCode==ENTER){ //Teleportation au passage à niveau
    println("Vous avez été téléporté au passage à niveau");
    posX = 14;
    posY = 17;
    dirZ = 0;
    niveauActuel = 0;
  }
  
  if (anim==0 && keyCode==SHIFT){ //Teleportation devant la pyramide
    println("Vous avez été téléporté à l'entrée de la pyramide");
    posX = 1;
    posY = -1;
    dirZ = 0;
    niveauActuel = 0;
    fantome = !fantome;
  }
  
  if (anim == 0 && keyCode==ALT){
    fantome = !fantome;
    if (fantome) println("Vous êtes en mode fantôme"); 
    else println("Vous n'êtes plus en mode fantôme");
  }

}





void buildLaby(char laby [][][], int dimension, int niveau){
  int todig = (dimension/2) * (dimension/2);
  int gx = 1;
  int gy = 1;
  while (todig>0 ) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4 + niveau*2)); // selon un tirage aleatoire
    if      (alea==0 && gx>1)          gx -= 2; // le fantome va a gauche
    else if (alea==1 && gy>1)          gy -= 2; // le fantome va en haut
    else if (alea==2 && gx<dimension-2) gx += 2; // .. va a droite
    else if (alea==3 && gy<dimension-2) gy += 2; // .. va en bas

    if (labyrinthe[niveau][gy][gx] == '.') {
      todig--;
      laby[niveau][gy][gx] = ' ';
      laby[niveau][(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }
}


PShape createMomieShape(){
  momie.scale(0.085);
  momie.translate(-45, -150, -25); // (1, 3)
  momie.rotateZ(PI);
  //momie.rotateZ(-PI/6);
  push();
    PShape corp = createShape();
    corp.beginShape(QUAD_STRIP);
    for (int z=-650; z<=450; z++){
      corp.noStroke();
      float y = random(50, 100);
      corp.fill(y+50+z/10.0, y+50+z/10.0, 10);
      float a = z/50.0*2*PI;
      float b = random(20, 30);
      float n = random(3, 4);
      float R2 = 200+((abs(z/(3.0+n))-200)*0.2)*cos(a)-abs(z/(3.0+n));
      corp.vertex((R2-50)*cos(a)/1.5, (R2-50)*sin(a)/1.5,(z+b-75)/2.0);
      corp.vertex((R2-50)*cos(a)/1.5, (R2-50)*sin(a)/1.5,(z+b)/2.0);
    }
    corp.endShape();
    momie.addChild(corp);
  pop();
  
  push();
    PShape tete = createShape();
    tete.translate (2, 0, 300);
    tete.beginShape(QUAD_STRIP);
    for (int z=-300; z<=300; z++){
      tete.noStroke();
      float y = random(100, 150);
      tete.fill(y+50+z/10.0, y+50+z/10.0, 10);
      float a = z/50.0*2*PI;
      float b = random(20, 30);
      float n = random(3, 4);
      float R2 = 200+((abs(z/(3.0+n))-200)*0.2)*cos(a)-abs(z/(3.0+n));
      tete.vertex((R2-50)*cos(a)/1.5, (R2-50)*sin(a)/1.5,(z+b-75)/4.0);
      tete.vertex((R2-50)*cos(a)/1.5, (R2-50)*sin(a)/1.5,(z+b)/4.0);
    }
    tete.endShape();
    momie.addChild(tete);
  pop();
  
  push();
    PShape brasd = createShape();
    brasd.beginShape(QUAD_STRIP);
    brasd.translate (30, 120, -185);
    brasd.rotateX(PI/2);
    for (int z=-100; z<=250; z++){
      brasd.noStroke();
      float y = random(100, 150);
      brasd.fill(y+50+z/10.0, y+50+z/10.0, 10);
      float a = z/50.0*2*PI;
      float b = random(20, 30);
      float n = random(3, 4);
      float R2 = 200+((abs(z/(3.0+n))-200)*0.2)*cos(a)-abs(z/(3.0+n));
      brasd.vertex((R2-50)*cos(a)/6, (R2-50)*sin(a)/6,(z+b-75)/2.0);
      brasd.vertex((R2-50)*cos(a)/10, (R2-50)*sin(a)/10,(z+b)/2.0);
    }
    brasd.endShape();
    momie.addChild(brasd);
  pop();
  
  push();
    PShape brasg = createShape();
    brasg.beginShape(QUAD_STRIP);
    brasg.translate (-50, 120, -185);
    brasg.rotateX(PI/2);
    for (int z=-100; z<=250; z++){
      brasg.noStroke();
      float y = random(100, 150);
      brasg.fill(y+50+z/10.0, y+50+z/10.0, 10);
      float a = z/50.0*2*PI;
      float b = random(20, 30);
      float n = random(3, 4);
      float R2 = 200+((abs(z/(3.0+n))-200)*0.2)*cos(a)-abs(z/(3.0+n));
      brasg.vertex((R2-50)*cos(a)/6, (R2-50)*sin(a)/6,(z+b-75)/2.0);
      brasg.vertex((R2-50)*cos(a)/10, (R2-50)*sin(a)/10,(z+b)/2.0);
    }
    brasg.endShape();
    momie.addChild(brasg);
  pop();
    
  push();
    fill(255);
    PShape oeild = createShape(ELLIPSE, 125, 200, 25,10);
    oeild.translate (-180, 95, -99.5);
    oeild.rotateX(PI/2);
    fill(0);
    PShape pupild = createShape(ELLIPSE, 125, 200, 5,5);
    pupild.translate (-180, 95, -99.5);
    pupild.rotateX(PI/2);
    momie.addChild(oeild);
    momie.addChild(pupild);
  pop();
  
  push();
    fill(255);
    PShape oeilg = createShape(ELLIPSE, 275, 200, 25, 10);
    oeilg.translate (-250, 95, -94.5);
    oeilg.rotateX(PI/2);
    fill(0);
    PShape pupilg = createShape(ELLIPSE, 275, 200, 5, 5);
    pupilg.translate (-250, 95, -94.5);
    pupilg.rotateX(PI/2);
    momie.addChild(oeilg);
    momie.addChild(pupilg);
  pop();
  
  PShape maind = loadShape("hand1.obj");
  
  push();
    maind.translate (-9.7, -33, 60);
    maind.rotateX(-PI/2);
    maind.scale(4);
    momie.addChild(maind);
  pop();
  
  PShape maing = loadShape("hand2.obj");
  
  push();
    maing.translate (2.7, -33, 60);
    maing.rotateX(-PI/2);
    maing.scale(4);
    momie.addChild(maing);
  pop();

  return momie;
}
