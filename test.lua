--PAROLE INTRECCIATE
--BY CAROSI ANDREA e FRACASCIA FILIPPO

--TODO 
--maybe implementabile le coroutine

--[[
Inizialmente ho interpretato male la traccia credendo che i file passati potessero essere .txt rappresentanti uno schema
ed una lista di parole
A fine progetto ho capito che stavo sbagliando così ho aggiunto delle funzioni 
per implementare l'utilizzo dei file .lua come schema e wordlist
Per questo motivo alcune funzioni potrebbero sembrare non utili o addirittura sbagliate se utilizzate con file .lua

Il possibile utilizzo di file .txt è rimasto nel progetto
]]

--Controllo se il file esiste ed è leggibile
--@param file è il file da aprire
--@return f o f=nil
function file_exists(file)
  local f = io.open(file, "r")
  if f then f:close() end
  return f ~= nil
end

--Leggi file e crea lo schema di lettere eseguendo i controlli
--@param file è il file da aprire
--@return matrice di lettere
function scomponi(file)
  if not file_exists(file) then print("?") return end
  if not controllo_len(file) then print("?") return end
  if not check_file_chars(file) then print("?") return end
  return makescheme(file)
end
  
  --Controlla se la lunghezza delle righe di un file selezionato è la stessa
  --@param file da controllare
  --@return nil se ci sono lunghezze diverse
function controllo_len(file)
  local contachar=0
  local cont=0
  local num_char_line=0 
  for line in io.lines(file) do 
    for i = 1, #line do   -- # serve per contare la lunghezza della string
      local c = line:sub(i,i)
      contachar=contachar+1
    end
    if cont==0 then num_char_line = contachar else end
    if num_char_line~=contachar then return nil end
    contachar=0
    cont=cont+1
  end
  return 1
end

--Controllo dei caratteri permessi sul file
--@param file
--@return 1 or nil se ci sono caratteri non validi
function check_file_chars(file)
  for line in io.lines(file) do 
    if not controllo_allowed_chars(line) then return nil end
  end
  return 1
end

--Controllo caratteri permessi sulla stringa data
--@param linea stringa
--@return 1 or nil se ci sono caratteri non permessi
function controllo_allowed_chars(line)
  for i = 1, #line do   -- # serve per contare la lunghezza della string
      local c = line:sub(i,i)
      if not string.match(c,'%a') then return nil end --%a indica letters (A-Z, a-z) https://riptutorial.com/lua/example/20315/lua-pattern-matching
    end
  return 1
end

--Separa i caratteri di una stringa
--@param line è la stringa
--@return vettore di caratteri
function split_line(line)
  local chars = {}
  for c in string.gmatch(line, ".") do
    chars[#chars+1] = c
  end
  return chars
end

--Crea lo schema
--@param file
--@return matrice schema riempita
function makescheme(file)
  local scheme = {}
  for line in io.lines(file) do 
    scheme[#scheme+1] = split_line(line)
  end
  return scheme
end

--Crea lista di parole dato un file
--@param file
--@return lista di parole
function make_list(file)
  lista={}
  for line in io.lines(file) do 
    lista[#lista+1]=line
  end
  return lista
end


--Function that seek for a word assuming the first letter of the word match with a scheme letter
--@param row
--@param column
--@param scheme
--@param word
--@return lista di coordinate or nil
function seeker(row,column,scheme,word) --https://www.geeksforgeeks.org/search-a-word-in-a-2d-grid-of-characters/
  local x={-1, -1, -1, 0, 0, 1, 1, 1}
  local y={-1, 0, 1, -1, 1, -1, 0, 1}
  local c= word:sub(1,1)
  local coords={}
  local coords_var = {}
  coords[#coords+1]={row,column}
  coords_var[#coords_var+1]={row,column}
  if scheme[row][column] ~= c then return nil end
  local len = string.len(word)
  
  for i=1,8 do
    local kappa=1
    local rd = row + x[i]
    local cd = column + y[i]
    
    for k=2,len do
      if rd> #scheme or rd < 1 or cd > #scheme[1] or cd <1 then break end
      if scheme[rd][cd] ~=  word:sub(k,k) then break end
      coords[#coords+1]={rd,cd}

      rd = rd + x[i]
      cd = cd + y[i]
      kappa=kappa+1
    end
    
  if kappa==len then return coord_finder(coords_var,coords,len) end
  end
  return nil
end

--Data una tabella di coordinate raw e la lunghezza della parola da cercare, restituisce la tabella di cordinate esatta
function coord_finder(coords_var,coords,len)
  --PER TUTTI I CONTROLLI DI SEGUITO
    --SAPPIAMO CHE se la parola scende lo schema la coordinata X aumenta, mentre se la parola sale la X diminuisce
    --SAPPIAMO CHE se la parola va verso destra la Y aumenta, se va verso sinistra la Y diminuisce
    
    --controllo se la parola va verso il basso
    if coords[1][1]<coords[#coords][1] then
      --controllo se va dritta
      if coords[1][2] == coords[#coords][2] then
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1]+i,coords[1][2]}
        end
      -- controllo se va in diagonale destra
      elseif coords[1][2] < coords[#coords][2] then
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1]+i,coords[1][2]+i}
        end
        --se non scende dritto ne verso destra allora per forza verso sinistra
      else
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1]+i,coords[1][2]-i}
        end
      end
    end
    
    --SUPPONGO CHE NELLA LISTA DI PAROLE CI SIANO PAROLE CON PIù DI 1 CARATTERE
    --controllo se la parola va in orizzontale
    if coords[1][1]==coords[#coords][1] then
      --controllo se va verso destra
      if coords[1][2]<coords[#coords][2] then
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1],coords[1][2]+i}
        end
        --va verso sinistra
      else
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1],coords[1][2]-i}
        end
      end
    end
    --controllo se la parola sale
    if coords[1][1]>coords[#coords][1] then
      --controllo se va dritta
      if coords[1][2] == coords[#coords][2] then
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1]-i,coords[1][2]}
        end
      -- controllo se va in diagonale destra
      elseif coords[1][2] < coords[#coords][2] then
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1]-i,coords[1][2]+i}
        end
        --se non sale dritto ne verso destra allora per forza verso sinistra
      else
        for i=1,len-1 do
          coords_var[#coords_var+1]={coords[1][1]-i,coords[1][2]-i}
        end
      end
    end
    
    return coords_var
end

--Function to search a given word into the scheme
--@param word to search
--@param scheme
--return list of coordinates of the given word
function pattern_search(scheme, word)
        local R = #scheme
        local C = #scheme[1]
        for row=1, R do
            for column=1, C do
                local coords=seeker(row, column, scheme, word)
                if scheme[row][column]==word:sub(1,1) and coords~=nil then return coords end
            end
        end
  return nil
end

--Function to iterate pattern search through the wordlist
--@param wordlist
--@param scheme
--return coordinates of all the words
function wordlist_iterate(wordlist, scheme)
  local coords={}
  for line in io.lines(wordlist) do
    local condition_coords=pattern_search(scheme,line)
    if not condition_coords then return nil else coords[#coords+1]=condition_coords end
  end
  return coords
end

function keyword (scheme, coords_to_check)
  local key=''
  local R = #scheme
  local C = #scheme[1]

  for _,j in pairs(coords_to_check) do
        for _,i in pairs(j) do 
        scheme[i[1]][i[2]] = 0
    end
  end
  for row=1, R do
    for column=1, C do
    if scheme[row][column]~=0 then key=key .. scheme[row][column] end
    end
  end
  return key
end

function getFileExtension(url)
  return url:match("^.+(%..+)$")
end

--Conta lunghezza tabella
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function controllo_allowed_chars_lua(T)
  for _,i in pairs(T) do 
    if not string.match(i,'%a') then return nil end
  end
  return 1
end

function wordlist_iterate_lua(wordlist, scheme)
  local coords={}
  for _,i in pairs(wordlist) do
    local line=table.concat(i,'')
    local condition_coords=pattern_search(scheme,line)
    if not condition_coords then return nil else coords[#coords+1]=condition_coords end
  end
  return coords
end
-------------------------------------------------------------------------------------------------------------------------
--assumo che lo schema passato come parametro possa essere un file .txt o un file .lua
--assumo che se il file è .lua lo schema viene chiamato "schema" e la wordlist "elenco"
file1=nil
scheme=nil

if getFileExtension(arg[1])==".lua" and getFileExtension(arg[2])==".lua" then 
  scheme=assert(loadfile(arg[1]),"File does not exist or wrong formatted!"); scheme()
  for _,i in pairs(schema) do
    if tablelength(i)~=tablelength(schema[1]) then return print("?") end
    if not controllo_allowed_chars_lua(i) then return print("?") end
  end
  wordlist=assert(loadfile(arg[2]),"File does not exist!"); wordlist()
  for _,i in pairs(elenco) do
    if not controllo_allowed_chars_lua(i) then return print("?") end
  end
  coords = wordlist_iterate_lua(elenco,schema)
  if not coords then return print("?") end
  key=keyword(schema,coords)
  if key~='' then return print("The mysterious key is...\"" .. key .. "\"") else return print("?") end
  
elseif
  getFileExtension(arg[1])==".txt" and getFileExtension(arg[2])==".txt" then
    file1=arg[1]
    scheme=scomponi(file1)
    wordlist=arg[2]
    if not check_file_chars(wordlist) then return print("?") end
    coords = wordlist_iterate(wordlist,scheme)
    if not coords then return print("?") end
    key=keyword(scheme,coords)
    if key~='' then return print("The mysterious key is...\"" .. key .. "\"") else return print("?") end
end


-------------------------------------------------------------------------------------------------------------------------