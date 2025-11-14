import Foundation

// --- Criar nome do mago ---
func criarMago() -> String {
    print("Digite o nome do seu mago:")
    if let nome = readLine(), !nome.trimmingCharacters(in: .whitespaces).isEmpty {
        return nome
    }
    return "Mago Anônimo"
}

// --- Escolher rank ---
func escolherRank() -> (String, Int) {
    print("""
Escolha o rank do seu mago:
1 - Aprendiz de Mago (20 pts)
2 - Mago Iniciante (40 pts)
3 - Feiticeiro (60 pts)
4 - Feiticeiro Experiente (80 pts)
5 - Mestre dos Magos (120 pts)
""")

    while let escolha = readLine(), let n = Int(escolha) {
        switch n {
            case 1: return ("Aprendiz de Mago", 20)
            case 2: return ("Mago Iniciante", 40)
            case 3: return ("Feiticeiro", 60)
            case 4: return ("Feiticeiro Experiente", 80)
            case 5: return ("Mestre dos Magos", 120)
            default: print("Escolha inválida. Tente novamente.")
        }
    }
    return ("Aprendiz de Mago", 20)
}

// --- Magias por rank ---
func magiasDisponiveis(rank: String) -> [String: Int] {
    switch rank {
        case "Aprendiz de Mago":
            return ["Bola de Fumaça": 5, "Faísca": 10]

        case "Mago Iniciante":
            return ["Bola de Fumaça": 5, "Faísca": 10, "Raio Mágico": 20]

        case "Feiticeiro":
            return ["Raio Mágico": 20, "Chamas Espirais": 30, "Orbe Arcano": 40]

        case "Feiticeiro Experiente":
            return ["Chamas Espirais": 30, "Orbe Arcano": 40, "Tempestade Arcana": 60]

        case "Mestre dos Magos":
            return ["Tempestade Arcana": 60, "Explosão Cósmica": 80, "Rasgo Dimensional": 100]

        default:
            return [:]
    }
}

// --- Escolher magias dentro do limite de pontos ---
func escolherMagias(pontos: Int, disponiveis: [String: Int]) -> [String] {
    var pontosRestantes = pontos
    var escolhidas: [String] = []

    print("\nMagias desbloqueadas pelo seu rank:")
    for (magia, custo) in disponiveis {
        print("• \(magia) — \(custo) pts")
    }

    while pontosRestantes > 0 {
        print("\nVocê tem \(pontosRestantes) pontos restantes.")
        print("Digite o nome da magia que deseja comprar ou 'sair':")

        if let entrada = readLine() {
            if entrada.lowercased() == "sair" {
                break
            }
            if let custo = disponiveis[entrada] {
                if custo <= pontosRestantes {
                    escolhidas.append(entrada)
                    pontosRestantes -= custo
                    print("Magia adicionada!")
                } else {
                    print("Pontos insuficientes!")
                }
            } else {
                print("Magia não encontrada!")
            }
        }
    }
    return escolhidas
}

// --- CENÁRIO FINAL ---
func iniciarAventura(nome: String, rank: String, magias: [String]) {
    print("\n===== 🎮 INICIANDO A AVENTURA =====")
    print("Mago: \(nome)")
    print("Rank: \(rank)")
    print("Magias escolhidas:")
    magias.forEach { print("• \($0)") }
    print("\nSeu mago entra em uma floresta sombria...")
    print("Uma criatura aparece e você se prepara para usar suas magias!")
}

// --- BATALHA DE TESTE ---
func batalha(mago: String, rank: String, magias: [String: Int], escolhidas: [String]) {

    // Vida do mago baseada no rank
    let vidaMagoInicial: Int = {
        switch rank {
            case "Aprendiz de Mago": return 60
            case "Mago Iniciante": return 80
            case "Feiticeiro": return 100
            case "Feiticeiro Experiente": return 120
            case "Mestre dos Magos": return 150
            default: return 80
        }
    }()

    var vidaMago = vidaMagoInicial
    var vidaInimigo = 100
    let danoInimigo = 12

    print("\n===== ⚔️ BATALHA DE TESTE =====")
    print("Um Goblin Arcano aparece!")
    print("Vida do Goblin: \(vidaInimigo)")
    print("Sua vida: \(vidaMago)\n")

    // Loop de batalha
    while vidaMago > 0 && vidaInimigo > 0 {

        print("\nSuas magias:")
        for (i, magia) in escolhidas.enumerated() {
            print("\(i+1) - \(magia) (\(magias[magia]!) de dano)")
        }

        print("Escolha uma magia (1-\(escolhidas.count)):")

        guard let entrada = readLine(),
              let escolha = Int(entrada),
              escolha >= 1 && escolha <= escolhidas.count else {
            print("Escolha inválida!")
            continue
        }

        let magiaSelecionada = escolhidas[escolha - 1]
        let dano = magias[magiaSelecionada]!

        print("\nVocê lançou \(magiaSelecionada)! Causou \(dano) de dano!")
        vidaInimigo -= dano

        if vidaInimigo <= 0 {
            print("\n🎉 VITÓRIA! O Goblin foi derrotado!")
            break
        }

        // Ataque do inimigo
        print("O Goblin atacou! Você perdeu \(danoInimigo) de vida!")
        vidaMago -= danoInimigo

        print("\nVida do Goblin: \(vidaInimigo)")
        print("Sua vida: \(vidaMago)")

        if vidaMago <= 0 {
            print("\n💀 DERROTA… O Goblin te derrotou.")
            break
        }
    }
}

// --- EXECUÇÃO GERAL ---
let nome = criarMago()
let (rank, pontos) = escolherRank()

let disponiveis = magiasDisponiveis(rank: rank)
let magiasEscolhidas = escolherMagias(pontos: pontos, disponiveis: disponiveis)

iniciarAventura(nome: nome, rank: rank, magias: magiasEscolhidas)

batalha(mago: nome, rank: rank, magias: disponiveis, escolhidas: magiasEscolhidas)
print("\nObrigado por jogar! Até a próxima aventura!")