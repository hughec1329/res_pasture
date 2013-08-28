

#paddocks {
  [cover >= 1700] { polygon-fill:#ae8; }
  [cover >= 2000] { polygon-fill:#594; }
  [cover >= 2500] { polygon-fill:#334a28; }
}

  
#paddocks {
  line-color:#594;
  line-width:0.5;
  polygon-opacity:0.5;
  polygon-fill:#ae8;
  polygon-gamma: 0.9;
}


#paddocks {
  text-name: [id] + '_' + '(' + [cover] + ')' ;
  text-face-name: "Ubuntu Mono Bold";
  text-fill: #030303;
  text-size: 15;
  text-name: [cover];
  text-halo-fill: fadeout(white, 30%);
  text-halo-radius: 2.5;
  text-wrap-width: 1;
  text-wrap-character: '_';
}
