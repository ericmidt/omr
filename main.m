%Authors: Eric Schmidt and Em�lio Dallastella

clear all; close all; clc;

pkg image load;

%l� as imagens
I = imread('preenchido2.png');

%refer�ncia do c�digo do come�o: https://www.mathworks.com/matlabcentral/answers/24943-detect-square-in-image
%tira o limiar, ou seja, t� encontrando o que limite entre o fundo e o
% que interessa.
%o limiar � um valor entre 0 e 255 que separa a imagem, o que for maior � 1
% e o que for menor � 0.
%graythresh faz um m�todo de achar o limiar, separa o fundo do que interessa
%o im2bw aplica essa limiar � sua imagem
%transforma tudo que n�o � branco e preto em branco e preto
Ibw = ~im2bw(I,graythresh(I));

%busca "buracos" na imagem, os quadrados das quest�es s�o preenchidos com 1
Ifill = imfill(Ibw,'holes');

%ele pega e exclui objetos com �rea menor que 400 / 120
%isso tira ru�do por exemplo
Iarea = bwareaopen(Ifill,400);

Ifinal = bwlabel(Iarea);

%ela mede propriedades de objetos. Ela encontra o centro do objetos
%o contorno dele
%a stat29 � a matriz que me diz onde t� cada coisa
stat29 = regionprops(Ifinal,'boundingbox');
%imprime a imagem original
figure(1); imshow(I); hold on;

%imprime os quadrados vermelhos na imagem
for cnt = 1 : numel(stat29) %pegando s� as quest�es
    bb = stat29(cnt).BoundingBox;
    rectangle('position',bb,'edgecolor','r','linewidth',2);
end
%colocando os tipos de prova em vetor e os removendo da matriz principal
for i = 1:4
   tipos_estruturas(i).BoundingBox = stat29(251).BoundingBox;
   stat29(251) = [];
end

%ordenando as caixas do tipo de prova 
  for i = 0:3 %bubble sort para o valor y
       for j = 1:4-i-1 
           if(tipos_estruturas(j).BoundingBox(2) > tipos_estruturas(j+1).BoundingBox(2))
                 temp0 = tipos_estruturas(j).BoundingBox;
                 tipos_estruturas(j).BoundingBox = tipos_estruturas(j+1).BoundingBox;
                 tipos_estruturas(j+1).BoundingBox = temp0;
           end
      end
  end
   
%ordenando respostas por y (ordenando de 1-50)
for j = 0:numel(stat29)-1
    for i = 1: numel(stat29)-j-1
        if stat29(i).BoundingBox(2) >stat29(i+1).BoundingBox(2)
            temp = stat29(i);
            stat29(i) = stat29(i+1);
            stat29(i+1) = temp;
        end
    end
end

%ordenando as estruturas (elementos do vetor stat29) em uma matriz
for i = 1:50
  for j = 1:5
        stat29(i,j).BoundingBox = stat29(i+j-1).BoundingBox; %coloca na linha
        if(j==5) %quando chegar em 5 elementos, apaga da coluna
           stat29(i+j-4,:) = [];
           stat29(i+j-4,:) = [];
           stat29(i+j-4,:) = [];
           stat29(i+j-4,:) = [];
        end
  end
end

%ordenando as linhas da matriz com base no valor em x (ordenando de A a E)
%fazendo um bubble sort para cada linha
for i = 1:50 %percorre as linhas de cima pra baixo 1 - 50
  for j = 0:4 %bubble sort em cada linha para o valor x
       for k = 1:5-j-1 
           if(stat29(i,k).BoundingBox(1) > stat29(i,k+1).BoundingBox(1))
                 temp1= stat29(i,k).BoundingBox;
                 stat29(i,k).BoundingBox = stat29(i,k+1).BoundingBox;
                 stat29(i,k+1).BoundingBox = temp1;
           end
      end
  end
end

%stat29 � a matriz com o mapa de onde est�o os quadrados das quest�es
%Ibw � a matriz com todos os pontos pretos (1) e brancos (0) da imagem
%usando stat29, podemos ver onde os quadrados est�o na imagem (e em Ibw)
%a�, � s� somar os elementos de cada �rea para saber se est� preenchido
%a �rea de cada quadrado � em torno de 33 x 18px = 594px
%e a �rea da imagem � 951 x 1226px = 1.165.926px


%acha os retangulos de stat29 no Ibw
indice_resposta = 1; %� usado para inserir os valores na linha certa da matriz resposta
for i = 1:50
    for j = 1:5
       caixa = imcrop(Ibw, stat29(i,j).BoundingBox); %imcrop pega os pontos em Ibw e coloca em caixa
       resposta(indice_resposta,1) = sum(caixa(:)); %� a matriz com a soma dos pixels
       indice_resposta = indice_resposta + 1;
    end
end

%ordenando os elementos do vetor resposta em uma matriz (de 250x1 para 50x5)
for i = 1:50
  for j = 1:5
        resposta(i,j) = resposta(i+j-1); %coloca na linha
        if(j==5) %quando chegar em 5 elementos, apaga da coluna
           resposta(i+j-4,:) = [];
           resposta(i+j-4,:) = [];
           resposta(i+j-4,:) = [];
           resposta(i+j-4,:) = [];
        end
  end
end

%lendo as respostas assinaladas (o �ndice do maior valor de cada linha
%ou nada caso esteja em branco)
%considerando acima de 420 pixels hachurado e abaixo de 420 / 140 n�o
respostas_aluno = [];
for i = 1:50
    [valor ind] = max(resposta(i,:)); %le o valor maximo de cada linha
    if(valor > 420)
        respostas_aluno = [respostas_aluno ind];
    end
    if(valor <= 420)
        respostas_aluno = [respostas_aluno 0];
    end
end


%verificando se mais de uma alternativa foi hachurada na mesma linha
%420 pixels hachurado e abaixo de 420 / 140 n�o
q_hachuradas_temp = 0;
quantidade_q_maisde1 = 0;
for i = 1:50
    for j = 1:5
        if(resposta(i,j) > 420)
            q_hachuradas_temp = q_hachuradas_temp + 1;
        end          
    end
    if(q_hachuradas_temp > 1) %anula a quest�o
        respostas_aluno(i) = -1;
        quantidade_q_maisde1 = quantidade_q_maisde1 + 1;
    end
     q_hachuradas_temp = 0;
 end

%lendo qual tipo de prova est� marcada
for i = 1:4
       caixa2 = imcrop(Ibw, tipos_estruturas(i).BoundingBox);
       tipos_provas(i,1) = sum(caixa2(:));
       
end


%retirando o tipo de prova da imagem (o �ndice do maior valor de cada linha)
tipo_escolhido = [];
[valor tipo_escolhido] = max(tipos_provas);

%caso o tipo de prova n�o tenha sido preenchido
%420 pixels hachurado e abaixo de 420 / 140 n�o
if(valor < 420)
   tipo_escolhido = 0;
end

%descobre qual tipo de prova �
% se for A, carrega o gabarito A, se for B, o B e etc
if(tipo_escolhido == 0)
  disp(['erro, tipo de prova n�o escolhido']);
  return;
end
if(tipo_escolhido == 1)
  G = imread('gabaritoA1.png');
end
if(tipo_escolhido == 2)
  G = imread('gabaritoB1.png');
end
if(tipo_escolhido == 3)
  G = imread('gabaritoC1.png');
end
if(tipo_escolhido == 4)
  G = imread('gabaritoD1.png');
end

%------------------- GABARITO ----------------------

%tira o limiar, ou seja, t� encontrando o que limite entre o fundo e o
% que interessa.
%o limiar � um valor entre 0 e 255 que separa a imagem, o que for maior � 1
% e o que for menor � 0.
%graythresh faz um m�todo de achar o limiar, separa o fundo do que interessa
%o im2bw aplica essa limiar � sua imagem
%transforma tudo que n�o � branco e preto em branco e preto
Gbw = ~im2bw(G,graythresh(G));

%busca "buracos" na imagem, os quadrados das quest�es s�o preenchidos com 1
Gfill = imfill(Gbw,'holes');

%ele pega e exclui objetos com �rea menor que 400
%isso tira ru�do por exemplo
Garea = bwareaopen(Gfill,400);

Gfinal = bwlabel(Garea);

%ela mede propriedades de objetos. Ela encontra o centro do objetos
%o contorno dele
%a stat29 � a matriz que me diz onde t� cada coisa
matriz_caixas_G = regionprops(Gfinal,'boundingbox');

%imprime a imagem original
figure(2); imshow(G); hold on;

%imprime os quadrados vermelhos na imagem
for cnt = 1 : numel(matriz_caixas_G) %pegando s� as quest�es
    bbg = matriz_caixas_G(cnt).BoundingBox;
    rectangle('position',bbg,'edgecolor','r','linewidth',2);
end

%colocando os tipos de prova em vetor e os removendo da matriz principal
for i = 1:4
   tipos_estruturas_G(i).BoundingBox = matriz_caixas_G(251).BoundingBox;
   matriz_caixas_G(251) = [];
end

%ordenando as caixas do tipo de prova
  for i = 0:3 %bubble sort para o valor y
       for j = 1:4-i-1 
           if(tipos_estruturas_G(j).BoundingBox(2) > tipos_estruturas_G(j+1).BoundingBox(2))
                 temp0_G = tipos_estruturas_G(j).BoundingBox;
                 tipos_estruturas_G(j).BoundingBox = tipos_estruturas_G(j+1).BoundingBox;
                 tipos_estruturas_G(j+1).BoundingBox = temp0_G;
           end
      end
  end

%ordenando respostas por y
for j = 0:numel(matriz_caixas_G)-1
    for i = 1: numel(matriz_caixas_G)-j-1
        if matriz_caixas_G(i).BoundingBox(2) > matriz_caixas_G(i+1).BoundingBox(2)
            temp1_G = matriz_caixas_G(i);
            matriz_caixas_G(i) = matriz_caixas_G(i+1);
            matriz_caixas_G(i+1) = temp1_G;
        end
    end
end

%ordenando as estruturas (elementos do vetor stat29) em uma matriz
for i = 1:50
  for j = 1:5
        matriz_caixas_G(i,j).BoundingBox = matriz_caixas_G(i+j-1).BoundingBox; %coloca na linha
        if(j==5) %quando chegar em 5 elementos, apaga da coluna
           matriz_caixas_G(i+j-4,:) = [];
           matriz_caixas_G(i+j-4,:) = [];
           matriz_caixas_G(i+j-4,:) = [];
           matriz_caixas_G(i+j-4,:) = [];
        end
  end
end

%ordenando as linhas da matriz com base no valor em x
for i = 1:50 %percorre as linhas de cima pra baixo 1 - 50
  for j = 0:4 %bubble sort em cada linha para o valor x
       for k = 1:5-j-1 
           if(matriz_caixas_G(i,k).BoundingBox(1) > matriz_caixas_G(i,k+1).BoundingBox(1))
                 temp2_G = matriz_caixas_G(i,k).BoundingBox;
                 matriz_caixas_G(i,k).BoundingBox = matriz_caixas_G(i,k+1).BoundingBox;
                 matriz_caixas_G(i,k+1).BoundingBox = temp2_G;
           end
      end
  end
end

%stat29 � a matriz com o mapa de onde est�o os quadrados das quest�es
%Ibw � a matriz com todos os pontos pretos (1) e brancos (0) da imagem
%usando stat29, podemos ver onde os quadrados est�o na imagem (e em Ibw)
%a�, � s� somar os elementos de cada �rea para saber se est� preenchido
%a �rea de cada quadrado � em torno de 33 x 18px = 594px
indice_resposta_G = 1;
for i = 1:50
    for j = 1:5
       caixa_G = imcrop(Gbw, matriz_caixas_G(i,j).BoundingBox);
       resposta_G(indice_resposta_G,1) = sum(caixa_G(:));
       indice_resposta_G = indice_resposta_G + 1;
    end
end

%ordenando os elementos do vetor resposta em uma matriz
for i = 1:50
  for j = 1:5
        resposta_G(i,j) = resposta_G(i+j-1); %coloca na linha
        if(j==5) %quando chegar em 5 elementos, apaga da coluna
           resposta_G(i+j-4,:) = [];
           resposta_G(i+j-4,:) = [];
           resposta_G(i+j-4,:) = [];
           resposta_G(i+j-4,:) = [];
        end
  end
end

%lendo as respostas assinaladas (o �ndice do maior valor de cada linha
%ou nada caso esteja em branco)
%considerando acima de 420 pixels hachurado e abaixo de 420 / 140 n�o
respostas_gabarito = [];
valor=0;
for i = 1:50
    [valor ind] = max(resposta_G(i,:));
    if(valor > 420)
        respostas_gabarito = [respostas_gabarito ind];
    end
    if(valor <= 420)
        respostas_gabarito = [respostas_gabarito 0];
    end
end


%comparando as respostas do aluno com as respostas do gabarito
nota = 0;
for i = 1:50
  if(respostas_aluno(i) == respostas_gabarito(i))
      nota=nota+1;
  end
end
disp(['A nota do aluno � ', num2str(nota)]);

disp(['Quantidade de quest�es com mais de uma alternativa preenchida � ', num2str(quantidade_q_maisde1)]);

