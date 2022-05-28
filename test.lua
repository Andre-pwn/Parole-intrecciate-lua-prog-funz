--PAROLE INTRECCIATE
--BY CAROSI ANDREA e FRACASCIA FILIPPO

--TODO 
--maybe implementabile coroutine

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
  if not file_exists(file) then print("Exception: error on opening the declared file") return end
  if not controllo_len(file) then print("Exception: input schema does not respect a valid format (lines-columns)") return end
  if not check_file_chars(file) then print("Exception: input file contains unvalid character set") return end
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
  local coords = {}
  coords[#coords+1]={row,column}
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
  if kappa==len then return coords end
  end
  return nil
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
                if scheme[row][column]==word:sub(1,1) and coords~=nil then print("Success: word \""..word.."\" has been found!") return coords end
            end
        end
  return nil
end

--Function to iterate pattern search through the wordlist
--@param wordlist
--@param scheme
--return coordinates of all the words
function wordlist_iterate(wordlist, scheme)
  for line in io.lines(wordlist) do
    local condition_coords=pattern_search(scheme,line)
    if not condition_coords then return nil else substitution(scheme,condition_coords) end
  end
  return 1
end
 
 
function substitution(scheme, coords)
  for _,i in pairs(coords) do
    scheme[i[1]][i[2]] = 0
  end
  return 1
end


function keyword (scheme)
  local key=''
  for i=1, #scheme do
    for j=1, #scheme[1] do 
      if scheme[i][j] ~= 0 then key= key .. scheme[i][j]end
    end
  end
  return key
end

-------------------------------------------------------------------------------------------------------------------------
file1=arg[1]
wordlist=arg[2]
scheme=scomponi(file1)
if not check_file_chars(wordlist) then print("Exception: there may be invalid characters in the wordlist") end
lista_parole= make_list(wordlist)
if not wordlist_iterate(wordlist,scheme) then print("Exception: word does not exist") end
-------------------------------------------------------------------------------------------------------------------------
print("The mysterious key is...\"" .. keyword(scheme) .. "\"")