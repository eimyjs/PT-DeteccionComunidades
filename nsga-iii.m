clear all
close all

%%%%%%%%%%% Generar instancias
% nodos = 36;
% A = zeros(nodos); % Inicializar matriz de adyacencia
% for i = 1:nodos-1
%     for j = i+1:nodos
%         y = rand;
%         if y > 0.6
%             A(i, j) = 1 + rand * 2;
%             A(j, i) = A(i, j);
%         end
%     end
% end
% Importar Datos
A1=importdata("base_1laura.txt");
A=A1.data;
[aA1,aA2]=size(A);
for i=1:aA1-1
    A(i,i)=0;
    for j=1+i:aA1
        A(i,j)=max([A(i,j),A(j,i)]);
        A(j,i)=A(i,j);
    end
end
nodos = aA1;
%%%%%%%%%%%%%%%%%%
grados = red(A); % Calcular grados
k = 2; % Tamaño mínimo de subgrupos
m_grado = ceil(mean(grados));

maxGenerations = 2100;
numberOfObjectives = 2;
mutationProbability = 0.2;
crossoverProbability = 0.95;
populationSize = 100;

%%%%%% Limpieza de red
[A, prohibidos, p] = limpiar_red(k, A, grados);
aux_12 = min([m_grado, k]);
max_comunidades = floor(p / (aux_12 + 1));

%%%%%%%%%%%%%%%% Generar población y evaluar objetivos
for iteracion = 1:20
    contador = 0;
    PF = [];
    PFE = [];
    for p = 1:populationSize
        m(p) = floor(2 + rand() * (max_comunidades - 2));
        population_1(p, :) = generar_poblacion(m(p), nodos, k, prohibidos, A);
        Evaluar_obj(p, :) = objetivo(A, k, population_1(p, :), m(p));
        if Evaluar_obj(p, 3) == 0 % Población factible
            contador = contador + 1;
            PF(contador, :) = population_1(p, :);
            PFE(contador, :) = Evaluar_obj(p, :);
        end
    end

    % Inicialización de NSGA-III
    for generacion = 1:maxGenerations
        % 1. Selección de puntos no dominados
        [front, ~] = non_dominated_sorting(PFE(:, 1:2));
        selected = PF(front == 1, :); % Soluciones no dominadas
        selected_objs = PFE(front == 1, :);

        % 2. Cruzamiento y Mutación
        offspring = [];
        offspring_objs = [];
        for i = 1:2:size(selected, 1)-1
            % Cruzamiento
            if rand < crossoverProbability
                [child1, child2] = crossover_with_feasibility(selected(i, :), selected(i+1, :), k, nodos);
                offspring = [offspring; child1; child2];
            end
            % Mutación
            if rand < mutationProbability
                mutant = mutate(selected(i, :), nodos);
                offspring = [offspring; mutant];
            end
        end

        % Evaluar nuevos hijos
        for i = 1:size(offspring, 1)
            offspring_objs(i, :) = objetivo(A, k, offspring(i, :), m(p));
        end

        % 3. Combinar poblaciones
        combined_population = [PF; offspring];
        combined_objs = [PFE; offspring_objs];

        % 4. Selección de las mejores soluciones
        [front, rank] = non_dominated_sorting(combined_objs(:, 1:2));
        [sorted_rank, indices] = sort(rank);
        % Filtrar soluciones únicas y factibles
        [unique_population, ia] = unique(combined_population, 'rows');
        unique_objs = combined_objs(ia, :);
        % Filtrar soluciones factibles (violaciones == 0)
        factibles = unique_objs(:, 3) == 0;
        filtered_population = unique_population(factibles, :);
        filtered_objs = unique_objs(factibles, :);
        
        % Quitar soluciones dominadas
        [front, ~] = non_dominated_sorting(filtered_objs(:, 1:2)); % Evaluar frente no dominado
        non_dominated = (front == 1); % Seleccionar soluciones no dominadas
        
        % Filtrar soluciones no dominadas
        filtered_population = filtered_population(non_dominated, :);
        filtered_objs = filtered_objs(non_dominated, :);
        
        % Eliminar soluciones duplicadas
        [filtered_objs, ia] = unique(filtered_objs, 'rows');
        filtered_population = filtered_population(ia, :);
        
        % Si las soluciones no dominadas exceden el tamaño permitido
        if size(filtered_population, 1) > populationSize
            % Seleccionar las soluciones más diversas
            selected_indices = select_most_diverse(filtered_objs(:, 1:2), populationSize);
            PF = filtered_population(selected_indices, :);
            PFE = filtered_objs(selected_indices, :);
        else
            PF = filtered_population;
            PFE = filtered_objs;
        end


    end
    % Guardar las soluciones finales en archivos
    nombre_archivo_PF = sprintf('PF_final_iter_%d.txt', iteracion);
    nombre_archivo_PFE = sprintf('PFE_final_iter_%d.txt', iteracion);
    save(nombre_archivo_PF, 'PF');
    save(nombre_archivo_PFE, 'PFE');

end

% Funciones auxiliares
function [g_1] = red(A)
    g_1 = sum(A > 0, 2); % Grado de cada nodo (número de conexiones)
end

function [A1, prohibidos, posibles] = limpiar_red(k, A, grados)
    [n, ~] = size(A);
    prohibidos = zeros(1, n);
    while true
        nodos_actualizados = false;
        for i = 1:n
            if prohibidos(i) == 0 && grados(i) < k
                prohibidos(i) = 1;
                A(i, :) = 0;
                A(:, i) = 0;
                nodos_actualizados = true;
            end
        end
        if ~nodos_actualizados
            break;
        end
        grados = red(A); % Recalcular grados
    end
    A1 = A;
    posibles = n - sum(prohibidos);
end

function [population_1] = generar_poblacion(m, nodos, k, prohibidos, A)
    solucion = zeros(1, nodos);
    visitados = zeros(1, nodos);

    % Asignar nodos a los subgrupos iniciales
    for grupo = 1:m
        nodo = randi([1, nodos]);
        while visitados(nodo) == 1 || prohibidos(nodo) == 1
            nodo = randi([1, nodos]);
        end
        solucion(nodo) = grupo;
        visitados(nodo) = 1;
    end

    % Asignar los nodos restantes a los subgrupos disponibles
    for nodo = 1:nodos
        if visitados(nodo) == 0 && prohibidos(nodo) == 0
            grupo_disponible = mod(nodo, m) + 1;
            solucion(nodo) = grupo_disponible;
        elseif prohibidos(nodo) == 1
            solucion(nodo) = 0;
        end
    end

    population_1 = solucion;
end

function [child1, child2] = crossover_with_feasibility(parent1, parent2, k, nodos)
    n = length(parent1);
    point = randi([1, n-1]);

    child1 = [parent1(1:point), parent2(point+1:end)];
    child2 = [parent2(1:point), parent1(point+1:end)];

    child1 = enforce_feasibility(child1, k, nodos);
    child2 = enforce_feasibility(child2, k, nodos);
end

function solution = enforce_feasibility(solution, k, nodos)
    grupos = unique(solution);
    for grupo = grupos'
        nodos_grupo = find(solution == grupo);
        if length(nodos_grupo) < k + 1
            for nodo = nodos_grupo'
                for g = grupos'
                    if g ~= grupo && sum(solution == g) >= k + 1
                        solution(nodo) = g;
                        break;
                    end
                end
            end
        end
    end

    % Revisar nodos individuales no asignados correctamente
    for i = 1:nodos
        if sum(solution == solution(i)) < k + 1
            new_group = max(solution) + 1;
            solution(i) = new_group;
        end
    end
end


function mutant = mutate(individual, nodos)
    pos = randi([1, length(individual)]);
    mutant = individual;
    mutant(pos) = randi([1, nodos]);
end

function [front, rank] = non_dominated_sorting(objs)
    n = size(objs, 1);
    dominated_count = zeros(n, 1); % Número de soluciones que dominan a cada solución
    dominates = cell(n, 1);       % Lista de soluciones dominadas por cada solución
    front = zeros(n, 1);
    rank = inf(n, 1);

    for i = 1:n
        for j = 1:n
            if i ~= j
                if dominates_solution(objs(i, :), objs(j, :))
                    dominates{i} = [dominates{i}, j];
                elseif dominates_solution(objs(j, :), objs(i, :))
                    dominated_count(i) = dominated_count(i) + 1;
                end
            end
        end
        if dominated_count(i) == 0
            front(i) = 1; % Solución no dominada
            rank(i) = 1;
        end
    end

    % Clasificar por frentes
    current_front = 1;
    while any(front == current_front)
        next_front = [];
        for i = find(front == current_front)'
            for j = dominates{i}
                dominated_count(j) = dominated_count(j) - 1;
                if dominated_count(j) == 0
                    rank(j) = current_front + 1;
                    next_front = [next_front, j];
                end
            end
        end
        current_front = current_front + 1;
        front(next_front) = current_front;
    end
end

function res = dominates_solution(a, b)
    res = all(a >= b) && any(a > b);
end


function res = dominates(a, b)
    res = all(a >= b) && any(a > b);
end

function [Evaluar_obj2] = objetivo(A, k, solution, m)
    [n, ~] = size(A);
    W = sum(A(:));
    ai = sum(A, 2); % Pesos de los nodos
    violaciones = 0;
    grupos = 0;
    q1 = -10000 * ones(1, m);

    for l = 1:m
        nodos_grupo = find(solution == l);
        if isempty(nodos_grupo)
            continue;
        end
        subA = A(nodos_grupo, nodos_grupo);
        
        % Verificar tamaño mínimo del grupo
        if length(nodos_grupo) <= k
            violaciones = violaciones + 100 * (length(nodos_grupo) + 1);
        else
            grupos = grupos + 1;
            
            % Calcular conectividad y penalizar si no está conectado
            G = graph(subA); % Crear grafo del subgrupo
            if max(conncomp(G)) ~= 1 % Si no está completamente conectado
                violaciones = violaciones + 100;
            end
            
            % Calcular Q_l
            subW = sum(subA(:));
            sub_ai = ai(nodos_grupo) .^ 2;
            q1(l) = (1 / W) * (subW - sum(sub_ai) / (4 * W));
        end
    end

    Evaluar_obj2 = [max(q1), grupos, violaciones];
end
