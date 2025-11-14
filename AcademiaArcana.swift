import Foundation

// ======================
// UTILITÁRIOS (funções)
// ======================

func inputLine() -> String {
    return readLine() ?? ""
}

func inputInt(prompt: String, min: Int? = nil, max: Int? = nil) -> Int {
    while true {
        print(prompt, terminator: " ")
        let line = inputLine().trimmingCharacters(in: .whitespacesAndNewlines)
        if let v = Int(line) {
            if let min = min, v < min { print("Digite um número >= \(min)."); continue }
            if let max = max, v > max { print("Digite um número <= \(max)."); continue }
            return v
        } else {
            print("Entrada inválida — digite um número.")
        }
    }
}

func waitEnter() {
    print("\n(aperte Enter para continuar)")
    _ = inputLine()
}

func rnd(_ a: Int, _ b: Int) -> Int {
    Int.random(in: a...b)
}

// ======================
// DADOS GLOBAIS
// ======================

var nomeMago = ""
var rankIndex = 0 // 0: Aprendiz, 1: Mago Iniciante, 2: Feiticeiro, 3: Feit. Experiente, 4: Mestre
var killCount = 0

let ranks = ["Aprendiz de Mago", "Mago Iniciante", "Feiticeiro", "Feiticeiro Experiente", "Mestre dos Magos"]

// Magias: (nome, dano, mana) - ordem = desbloqueio por rank
let magiasBanco: [(String, Int, Int)] = [
    ("Raio Mágico", 20, 15),         // nível baixo
    ("Toque Arcano", 12, 6),         // segunda magia para Aprendiz
    ("Orbe Arcano", 35, 25),         // rank 1
    ("Lança Congelante", 50, 35),    // rank 2
    ("Tempestade de Mana", 75, 50),  // rank 3
    ("Explosão Arcana Final", 120, 70) // rank 4 (opcional extra)
]

// Vida e mana por rank (mesma ordem de 'ranks')
let vidaPorRankArr = [80, 100, 120, 150, 190]
let manaPorRankArr = [60, 70, 80, 95, 120]

// Inimigos base (4). A função de gerar trata escalonamento por rank.
let inimigosBase = ["Lobo Sombrio", "Soldado Arcano Corrompido", "Golem de Pedra Mística", "Dragão Menor Carmesim"]

// ======================
// FUNÇÕES DE JOGO
// ======================

func mostrarTitulo() {
    print("""
    
    =====================================
            ACADEMIA ARCANA (CLI)
    =====================================
    """)
}

func escolherNome() {
    print("Digite o nome do seu mago:")
    let line = inputLine().trimmingCharacters(in: .whitespacesAndNewlines)
    nomeMago = line.isEmpty ? "Mago Anônimo" : line
}

// Ajuste de liberação: Aprendiz (rankIndex 0) tem 2 magias; depois cada rank libera +1 até o máximo do banco.
func magiasDisponiveisParaRank(_ idx: Int) -> [(String, Int, Int)] {
    // quantidade = min(totalDoBanco, 2 + idx)
    let quantidade = min(magiasBanco.count, 2 + idx)
    return Array(magiasBanco[0..<quantidade])
}

func gerarInimigoParaRank(_ idx: Int) -> (nome: String, vida: Int, danoMin: Int, danoMax: Int) {
    let escolhido = inimigosBase.randomElement()!
    switch escolhido {
    case "Lobo Sombrio":
        switch idx {
        case 0: return (escolhido, rnd(20,30), 3,6)         // muito mais fácil no início
        case 1: return (escolhido, rnd(40,55), 5,9)
        case 2: return (escolhido, rnd(55,70), 8,12)
        case 3: return (escolhido, rnd(70,90), 11,16)
        default: return (escolhido, rnd(120,150), 18,25)
        }
    case "Soldado Arcano Corrompido":
        switch idx {
        case 0: return (escolhido, rnd(30,45), 6,9)
        case 1: return (escolhido, rnd(60,80), 8,12)
        case 2: return (escolhido, rnd(80,100), 11,15)
        case 3: return (escolhido, rnd(100,130), 14,19)
        default: return (escolhido, rnd(160,200), 20,26)
        }
    case "Golem de Pedra Mística":
        switch idx {
        case 0: return (escolhido, rnd(50,70), 8,12)
        case 1: return (escolhido, rnd(80,100), 10,15)
        case 2: return (escolhido, rnd(100,130), 13,18)
        case 3: return (escolhido, rnd(130,170), 17,23)
        default: return (escolhido, rnd(210,260), 24,30)
        }
    default: // Dragão
        switch idx {
        case 0: return (escolhido, rnd(60,80), 10,14)
        case 1: return (escolhido, rnd(120,150), 14,20)
        case 2: return (escolhido, rnd(150,180), 17,23)
        case 3: return (escolhido, rnd(180,230), 21,28)
        default: return (escolhido, rnd(300,350), 30,40)
        }
    }
}

func mostrarMagias(_ lista: [(String, Int, Int)]) {
    print("\nSuas magias:")
    for (i, t) in lista.enumerated() {
        print("\(i+1) - \(t.0) (Dano: \(t.1) | Mana: \(t.2))")
    }
}

func atualizarRank() {
    // rankIndex é determinado por killCount: 0..4
    let novo = min(4, killCount) // killCount 0->0, 1->1, ..., 4+ ->4
    if novo != rankIndex {
        rankIndex = novo
        print("\n✨ Você alcançou novo rank: \(ranks[rankIndex])!")
        waitEnter()
    }
}

func mostrarStatusGeral() {
    print("\n===== STATUS =====")
    print("Mago: \(nomeMago)")
    print("Rank: \(ranks[rankIndex]) (Kills: \(killCount))")
    print("Vida Máx: \(vidaPorRankArr[rankIndex]) | Mana Máx: \(manaPorRankArr[rankIndex])")
    let magias = magiasDisponiveisParaRank(rankIndex)
    mostrarMagias(magias)
    print("==================")
}

// ======================
// SISTEMA DE BATALHA (um combate por execução)
// ======================

func batalhaSimples() -> Bool {
    // estado do jogador (vida/mana iniciam cheios)
    var vida = vidaPorRankArr[rankIndex]
    var mana = manaPorRankArr[rankIndex]
    
    // obter magias disponíveis
    let magias = magiasDisponiveisParaRank(rankIndex) // [(nome,dano,mana)]
    
    // gerar inimigo escalado
    let inimigo = gerarInimigoParaRank(rankIndex)
    var vidaInimigo = inimigo.vida
    
    print("\n=== BATALHA INICIADA ===")
    print("Inimigo: \(inimigo.nome) — HP: \(vidaInimigo) | Dano: \(inimigo.danoMin)-\(inimigo.danoMax)")
    print("Você: \(nomeMago) — Rank: \(ranks[rankIndex]) | Vida: \(vida) | Mana: \(mana)")
    
    // controle de combos usados nessa batalha (não permitir repetir o mesmo combo nesta batalha)
    var combosUsados: Set<String> = Set()
    
    // loop de combate
    while vida > 0 && vidaInimigo > 0 {
        print("\nSua Vida: \(vida) | Mana: \(mana)")
        print("Vida do \(inimigo.nome): \(vidaInimigo)")
        mostrarMagias(magias)
        print("9 - Abrir menu de combos")
        print("0 - Ver status")
        
        let escolha = inputInt(prompt: "Escolha ação (número):", min: 0, max: 9)
        
        if escolha == 0 {
            mostrarStatusGeral()
            continue
        } else if escolha == 9 {
            // mostrar combos possíveis numerados (combos são pares i,j com i < j -> diferentes)
            var combos: [(String, Int, Int)] = [] // (nomeCombo, custoMana, danoCombo)
            var idxMap: [(Int, Int)] = []
            for i in 0..<magias.count {
                for j in (i+1)..<magias.count { // j starts at i+1 to force different spells
                    let m1 = magias[i]
                    let m2 = magias[j]
                    let custo = max(0, m1.2 + m2.2 - 5)
                    let dano = m1.1 + m2.1 + 10
                    let nomeCombo = "\(m1.0)+\(m2.0)"
                    combos.append((nomeCombo, custo, dano))
                    idxMap.append((i,j))
                }
            }
            if combos.isEmpty {
                print("\nNenhum combo disponível (você precisa de pelo menos 2 magias).")
                continue
            }
            // exibir combos
            print("\n--- COMBOS DISPONÍVEIS ---")
            for (k, c) in combos.enumerated() {
                print("\(k+1) - \(c.0) (Custo Mana: \(c.1) | Dano: \(c.2)) \(combosUsados.contains(c.0) ? "[JÁ USADO]" : "")")
            }
            print("0 - Voltar")
            let escolhaCombo = inputInt(prompt: "Escolha combo (número):", min: 0, max: combos.count)
            if escolhaCombo == 0 {
                continue
            } else {
                let c = combos[escolhaCombo - 1]
                if combosUsados.contains(c.0) {
                    print("⚠️ Você não pode repetir o mesmo combo dentro desta batalha.")
                    continue
                }
                if mana < c.1 {
                    print("Mana insuficiente para esse combo (custa \(c.1)).")
                    continue
                }
                // aplicar combo
                mana -= c.1
                vidaInimigo -= c.2
                combosUsados.insert(c.0)
                print("\n🔥 Você usou o combo \(c.0)! Causou \(c.2) de dano. (Mana restante: \(mana))")
            }
        } else {
            // ataque básico = escolher magia por número
            if escolha < 1 || escolha > magias.count {
                print("Escolha inválida.")
                continue
            }
            let sel = magias[escolha - 1]
            let nomeMag = sel.0; let dano = sel.1; let custo = sel.2
            if mana < custo {
                print("Mana insuficiente para \(nomeMag) (custa \(custo)).")
                continue
            }
            mana -= custo
            vidaInimigo -= dano
            print("\n✨ Você lançou \(nomeMag)! Causou \(dano) de dano. (Mana restante: \(mana))")
        }
        
        // verificações pós-ataque
        if vidaInimigo <= 0 {
            print("\n🏆 Você derrotou o \(inimigo.nome)!")
            killCount += 1
            atualizarRank()
            // recuperar parte da vida/mana após vitória (25%)
            let recVida = min(vidaPorRankArr[rankIndex], vida + Int(Double(vidaPorRankArr[rankIndex]) * 0.25))
            let recMana = min(manaPorRankArr[rankIndex], mana + Int(Double(manaPorRankArr[rankIndex]) * 0.25))
            vida = recVida
            mana = recMana
            print("Recuperou um pouco após a vitória. Vida: \(vida) | Mana: \(mana)")
            waitEnter()
            return true
        }
        
        // turno inimigo
        let danoInimigo = rnd(inimigo.danoMin, inimigo.danoMax)
        vida -= danoInimigo
        print("⚔️ O \(inimigo.nome) atacou! Você perdeu \(danoInimigo) de vida.")
        if vida <= 0 {
            print("\n💀 Você foi derrotado pelo \(inimigo.nome)...")
            // penalidade simples: mantém killCount, player não perde rank, apenas recupera parcialmente
            let recVida = max(1, Int(Double(vidaPorRankArr[rankIndex]) * 0.25))
            let recMana = max(0, Int(Double(manaPorRankArr[rankIndex]) * 0.25))
            print("Você acorda ferido. Vida restaurada para \(recVida). Mana: \(recMana).")
            waitEnter()
            return false
        } else {
            print("Sua vida atual: \(vida)")
        }
    }
    return false
}

// ======================
// MENU PRINCIPAL E FLUXO
// ======================

func menuPrincipal() {
    while true {
        mostrarTitulo()
        print("1 - Começar jogo")
        print("2 - Sair")
        let op = inputInt(prompt: "Escolha (1-2):", min:1, max:2)
        if op == 2 { print("Saindo... até a próxima!"); exit(0) }
        // iniciar
        escolherNome()
        killCount = 0
        rankIndex = 0
        print("\nBem-vindo, \(nomeMago)! Você começa como \(ranks[rankIndex]). Boa sorte.")
        waitEnter()
        jogoLoop()
    }
}

func jogoLoop() {
    while true {
        print("\n--- MENU ---")
        print("1 - Entrar em batalha")
        print("2 - Ver status")
        print("3 - Ver magias desbloqueadas")
        print("4 - Sair para título")
        let op = inputInt(prompt: "Escolha (1-4):", min:1, max:4)
        if op == 1 {
            let venceu = batalhaSimples()
            if rankIndex == 4 {
                // final épico
                mostrarFinal()
                exit(0)
            }
            if !venceu {
                // após derrota, oferecer continuar ou sair
                print("\n1 - Tentar novamente (outra batalha)")
                print("2 - Voltar ao menu")
                let r = inputInt(prompt: "Escolha (1-2):", min:1, max:2)
                if r == 2 { continue }
            }
        } else if op == 2 {
            mostrarStatusGeral()
            waitEnter()
        } else if op == 3 {
            let lista = magiasDisponiveisParaRank(rankIndex)
            mostrarMagias(lista)
            // também mostrar combos sugeridos (somente pares possíveis)
            print("\nCombos sugeridos (ex.: 1+2):")
            for i in 0..<lista.count {
                for j in (i+1)..<lista.count { // apenas pares diferentes
                    let nomeCombo = "\(lista[i].0) + \(lista[j].0)"
                    let custo = max(0, lista[i].2 + lista[j].2 - 5)
                    let dano = lista[i].1 + lista[j].1 + 10
                    print("- \(nomeCombo) (custo: \(custo) mana | dano: \(dano))")
                }
            }
            waitEnter()
        } else {
            print("Voltando ao título...")
            break
        }
    }
}

func mostrarFinal() {
    print("""

    🌟🌌 FINALE — O APICE DO PODER ARCANO 🌌🌟

    Ao alcançar o título de Mestre dos Magos, sua aura explode em uma luz que rompe o velo do tempo.
    As lendas sussurram seu nome e as estrelas alinham-se em saudação ao seu poder.

    Todas as magias se curvam ao seu comando. Seu legado será contado através dos séculos.
    Parabéns, \(nomeMago) — Mestre dos Magos!

    FIM DA JORNADA... por enquanto.

    """)
    waitEnter()
}

// ======================
// INÍCIO
// ======================
menuPrincipal()
