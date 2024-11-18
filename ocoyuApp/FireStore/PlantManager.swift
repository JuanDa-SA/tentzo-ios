//
//  PlantManager.swift
//  ocoyuApp
//
//  Created by Javier Cuatepotzo on [fecha].
//

import Foundation
import FirebaseFirestore

struct Plant: Codable {
    let plantId: String
    let name: String
    let scientificName: String?
    let description: String?
    let url: String?
//    let fuente: String?
    let dateAdded: Date?
    let imageUrl: String

}

final class PlantManager {
    
    static let shared = PlantManager()
    private init() { }
    private let plantCollection = Firestore.firestore().collection("plants")
    
    private func plantDocument(plantId: String) -> DocumentReference {
        plantCollection.document(plantId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func addNewPlant(plant: Plant) async throws {
        try plantDocument(plantId: plant.plantId).setData(from: plant, merge: false, encoder: encoder)
    }
    
    func getPlant(plantId: String) async throws -> Plant {
        try await plantDocument(plantId: plantId).getDocument(as: Plant.self, decoder: decoder)
    }
    
//    func updatePlant(plantId: String, updatedPlant: Plant) async throws {
//        try await plantDocument(plantId: plantId).setData(from: updatedPlant, merge: true, encoder: encoder)
//    }
    
    func deletePlant(plantId: String) async throws {
        try await plantDocument(plantId: plantId).delete()
    }
    
    func getAllPlants() async throws -> [Plant] {
        let snapshot = try await plantCollection.getDocuments()
        return try snapshot.documents.map { try $0.data(as: Plant.self, decoder: decoder) }
    }
    
    func getPlantByScientificName(scientificName: String) async throws -> Plant? {
        let querySnapshot = try await plantCollection
            .whereField("scientific_name", isEqualTo: scientificName)
            .getDocuments()

        // Si hay un resultado, devolvemos la primera planta
        guard let document = querySnapshot.documents.first else {
            return nil
        }
        
        return try document.data(as: Plant.self, decoder: decoder)
    }
    
//    func getFirstMatchingPlant(scientificNames: [String]) async throws -> Plant? {
//        for name in scientificNames {
//            
//            let querySnapshot = try await plantCollection
//                .whereField("scientific_name", isEqualTo: name)
//                .getDocuments()
//
//            if let document = querySnapshot.documents.first {
//                print(name)
//                return try document.data(as: Plant.self, decoder: decoder)
//            }
//        }
//        return nil
//    }
    func getFirstMatchingPlant(scientificNames: [String]) async throws -> Plant? {
        for name in scientificNames {
            print(name)
            print("Buscando coincidencia para: \(name)1")
            
            // Realizamos la consulta en Firestore
            let querySnapshot = try await plantCollection
                .whereField("scientific_name", isEqualTo: name)
                .getDocuments()
            
            // Recorremos los documentos encontrados (si los hay)
            for document in querySnapshot.documents {
                if let firestoreName = document.get("scientific_name") as? String {
                    print("Comparando \(name) con \(firestoreName)")
                }
            }

            // Si encontramos el primero, lo devolvemos
            if let document = querySnapshot.documents.first {
                print("Coincidencia encontrada: \(name)")
                return try document.data(as: Plant.self, decoder: decoder)
            }
        }
        print("No se encontró coincidencia")
        return nil
    }
    
    func addSamplePlants() async throws {
        let samplePlants: [Plant] = [
            Plant(plantId: "1", name: "Huinare blanco", scientificName: "Sida abutifolia", description: "La Huinare blanco (Sida abutifolia) es una planta discreta pero resistente, originaria de regiones áridas de América como México y el suroeste de los Estados Unidos. De pequeño tamaño, con hojas aterciopeladas y flores blancas o amarillentas, crece en suelos pobres, bordes de caminos y áreas perturbadas, donde contribuye a la protección del suelo y sustenta insectos polinizadores. Además de su valor ecológico, ha sido usada en la medicina tradicional para tratar heridas e inflamaciones. Su capacidad de prosperar en condiciones adversas la convierte en un símbolo de adaptabilidad y fortaleza en los ecosistemas áridos.", url: "http://www.conabio.gob.mx/malezasdemexico/malvaceae/sida-abutifolia/fichas/ficha.htm", dateAdded: Date(), imageUrl:"http://www.conabio.gob.mx/malezasdemexico/malvaceae/sida-abutifolia/fichas/ficha.htm"),
            Plant(plantId: "2", name: "Tepehuaje", scientificName: "Lysiloma acapulcense", description: "El Tepehuaje (Lysiloma acapulcense) es un árbol nativo de México y América Central, conocido por su adaptabilidad a climas cálidos y suelos pobres. Puede alcanzar hasta 15 metros de altura, con un tronco recto, corteza rugosa y follaje denso compuesto por hojas pequeñas y bipinnadas. Sus flores blancas y esponjosas, dispuestas en racimos, atraen a polinizadores, mientras que sus vainas alargadas contienen semillas que contribuyen a su propagación.Este árbol es valorado no solo por su aporte ecológico, como la fijación de nitrógeno al suelo y la sombra que proporciona en paisajes áridos, sino también por sus usos tradicionales. Su madera es empleada en construcción y carpintería, mientras que en la medicina popular se aprovechan sus propiedades para tratar infecciones y problemas de la piel. Resiliente y útil, el Tepehuaje es una especie clave en los ecosistemas que habita.", url: "https://mexico.inaturalist.org/taxa/138912-Lysiloma-acapulcense",
                   dateAdded: Date(), imageUrl:"https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F2.jpeg?alt=media&token=5e193344-45ac-493f-94ae-737bb42a5950" ),
            Plant(plantId: "3", name: "Árbol del borrego", scientificName: "Acacia acatlensis", description: "El Árbol del borrego (Acacia acatlensis) es un árbol nativo de México, típico de climas secos y semisecos, especialmente en áreas montañosas. Puede crecer hasta 10 metros de altura, con ramas espinosas, corteza rugosa y hojas pequeñas y bipinnadas que le otorgan un follaje fino. Sus flores, agrupadas en esferas amarillas y fragantes, destacan por su capacidad de atraer polinizadores, mientras que sus vainas alargadas contienen semillas que dispersa fácilmente. Este árbol es apreciado tanto por su capacidad para estabilizar suelos y enriquecerlos con nitrógeno como por sus usos tradicionales. Su madera se utiliza en la fabricación de herramientas y leña, y su sombra es ideal para el descanso de ganado, de ahí su nombre común. Adaptable y resistente, el Árbol del borrego es un aliado importante en la conservación de ecosistemas áridos y semiáridos.", url: "https://mexico.inaturalist.org/taxa/75833-Boerhavia-coccinea", dateAdded: Date(), imageUrl:"https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F3.jpeg?alt=media&token=0f2b355b-3499-4885-a5c5-e2f64e973e48"),
            Plant(
                plantId: "4",
                name: "Hierba Mariposa",
                scientificName: "Lantana achyranthifolia",
                description: "La Hierba Mariposa es una planta arbustiva originaria de regiones áridas y semiáridas de México y América Central. De porte bajo, sus hojas rugosas y sus pequeñas flores, que varían entre tonos amarillos y naranjas, la hacen llamativa en paisajes secos. Esta planta es conocida por atraer mariposas e insectos polinizadores, desempeñando un papel clave en la biodiversidad local. Resistente y adaptable, suele crecer en suelos pobres y áreas perturbadas. Tradicionalmente, se le han atribuido propiedades medicinales para tratar infecciones leves y problemas cutáneos. La Hierba Mariposa combina belleza, funcionalidad ecológica y usos tradicionales.",
                url: "https://mexico.inaturalist.org/taxa/164421-Lantana-achyranthifolia",
                dateAdded: Date(),
                imageUrl:"https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F4.jpg?alt=media&token=a909c195-898f-4a61-b271-5ea999ca281f"
            ),
            Plant(
                plantId: "5",
                name: "Cacaloxochitl",
                scientificName: "Plumeria acutifolia",
                description: "El Cacaloxochitl, también conocido como frangipani o flor de mayo, es un árbol tropical emblemático de México. Su altura alcanza entre 5 y 8 metros, con ramas gruesas y hojas alargadas de un verde intenso. Sus flores, grandes y fragantes, combinan tonos blancos y amarillos, siendo altamente valoradas tanto por su belleza como por su aroma. Este árbol tiene un significado cultural importante en la medicina tradicional y la espiritualidad mesoamericana, donde se asocia con rituales y ofrendas. Además, su savia tiene aplicaciones medicinales. El Cacaloxochitl es un símbolo de la riqueza natural y cultural de los paisajes tropicales mexicanos.",
                url:"http://www.medicinatradicionalmexicana.unam.mx/apmtm/termino.php?l=3&t=plumeria-acutifolia",
                dateAdded: Date(),
                imageUrl:"https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F5.jpeg?alt=media&token=93963b78-6482-4ea8-9595-e58895e277b8"
            ),
            Plant(
                plantId: "6",
                name: "Pochote",
                scientificName: "Ceiba aesculifolia",
                description: "El Pochote (Ceiba aesculifolia) es un árbol majestuoso y emblemático de México y América Central, que destaca en climas cálidos y secos. Puede alcanzar alturas de hasta 25 metros, con un tronco robusto cubierto de espinas cónicas que lo protegen de herbívoros. Sus hojas palmeadas caen en la temporada seca, y sus flores grandes, blancas o rosadas, emergen al final del invierno, atrayendo polinizadores como murciélagos y aves. Este árbol es altamente valorado por su fibra, utilizada en la fabricación de textiles y cuerdas, así como por sus semillas ricas en aceite. En la cultura tradicional, se asocia con la protección espiritual y se emplea en remedios para tratar inflamaciones y problemas respiratorios. Resiliente y de gran importancia ecológica y cultural, el Pochote es un símbolo de fortaleza en los ecosistemas secos de Mesoamérica.",
                url: "https://mexico.inaturalist.org/taxa/209891-Ceiba-aesculifolia",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F6.jpg?alt=media&token=be8710ea-4b66-4259-97e2-b0cfe1280176"
            ),
            Plant(
                plantId: "7",
                name: "Elotes de coyote",
                scientificName: "Conopholis alpina",
                description: "Los Elotes de coyote (Conopholis alpina) son plantas parásitas nativas de los bosques montañosos de México y América Central, especialmente en zonas de pino-encino. Carecen de clorofila y dependen de las raíces de árboles anfitriones para obtener nutrientes. Su peculiar apariencia, similar a pequeñas mazorcas amarillas o marrones, les da su nombre común. Aunque son poco conocidas, estas plantas tienen un papel ecológico importante al integrarse en la dinámica de los bosques donde habitan. En la medicina tradicional, se les han atribuido propiedades para tratar problemas gastrointestinales. Los Elotes de coyote son un ejemplo fascinante de adaptación y supervivencia en los ecosistemas montañosos.",
                url: "https://mexico.inaturalist.org/taxa/59983-Conopholis-alpina",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F7.jpg?alt=media&token=f4f056ea-dd47-4187-a704-aa6d2b43cd97"
            ),
            Plant(
                plantId: "8",
                name: "Epazote",
                scientificName: "Chenopodium ambrosioides",
                description: "El Epazote es una hierba aromática nativa de América que se cultiva ampliamente en México por su uso culinario y medicinal. Con hojas alargadas y aroma intenso, es un ingrediente esencial en platillos tradicionales como los frijoles y salsas. También se le atribuyen propiedades medicinales, especialmente para aliviar problemas digestivos y parásitos intestinales. Su resistencia lo hace crecer en suelos pobres y áreas perturbadas.",
                url: "http://www.conabio.gob.mx/malezasdemexico/chenopodiaceae/chenopodium-ambrosioides/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F8.jpeg?alt=media&token=c22241de-f51d-491f-96c2-66f56e1e5ad6"
            ),
            Plant(
                plantId: "9",
                name: "Hierba mora",
                scientificName: "Solanum americanum",
                description: "La Hierba mora es una planta herbácea de crecimiento rápido que se encuentra en terrenos baldíos, bordes de caminos y campos cultivados en climas cálidos y húmedos. Sus hojas son comestibles cuando se preparan adecuadamente, y sus pequeñas bayas negras han sido usadas en medicina tradicional, aunque contienen alcaloides que pueden ser tóxicos si no se manejan con cuidado. En la herbolaria, se utiliza para tratar inflamaciones, dolores de muelas y problemas cutáneos. Aunque sencilla, la Hierba mora juega un papel ecológico importante al ser refugio y alimento para insectos y aves.",
                url: "http://www.conabio.gob.mx/malezasdemexico/solanaceae/solanum-americanum/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F9.jpeg?alt=media&token=33c00edd-2ce9-4ed7-83df-6a4d73eee957"
            ),
            Plant(
                plantId: "10",
                name: "Acahual",
                scientificName: "Simsia amplexicaulis",
                description: "El Acahual es un arbusto típico de terrenos abandonados, bordes de caminos y campos agrícolas, donde actúa como una planta pionera que protege el suelo de la erosión. Sus flores amarillas, parecidas a pequeños girasoles, son muy atractivas para polinizadores como abejas y mariposas, promoviendo la biodiversidad. En la medicina tradicional, se le atribuyen propiedades para tratar enfermedades respiratorias, fiebres y dolores musculares. Además de su relevancia ecológica y medicinal, el Acahual es un recordatorio del equilibrio entre naturaleza y aprovechamiento humano.",
                url: "http://www.conabio.gob.mx/malezasdemexico/asteraceae/simsia-amplexicaulis/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F10.jpg?alt=media&token=589e2a42-2806-4dea-a88f-9968c4ddb93e"
            ),
            Plant(
                plantId: "11",
                name: "Hinchador",
                scientificName: "Pseudosmodingium andreux",
                description: "El Hinchador es un árbol endémico de México, característico de los bosques secos y montañosos. Su savia es altamente tóxica y puede causar inflamaciones severas en la piel al contacto, de ahí su nombre común. Sin embargo, este árbol también tiene aplicaciones medicinales en dosis controladas, utilizadas tradicionalmente para tratar afecciones reumáticas y dolores musculares. Su madera es dura y resistente, aunque poco utilizada debido a su toxicidad. El Hinchador es un ejemplo de la complejidad de las plantas nativas, que combinan propiedades beneficiosas y riesgosas.",
                url: "https://mexico.inaturalist.org/taxa/287428-Pseudosmodingium-andrieuxii",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F11.jpeg?alt=media&token=71484e6c-5af4-4e97-a504-14f7f13dc847"
            ),
            Plant(
                plantId: "12",
                name: "Bacanora",
                scientificName: "Agave angustifolia",
                description: "El Bacanora es una especie de agave nativa de las regiones áridas del norte de México, especialmente en Sonora. Reconocido por sus largas hojas puntiagudas y su capacidad de adaptación a climas secos, es el corazón de la producción de la bebida destilada que lleva su nombre. Este agave no solo tiene importancia cultural y económica, sino que también es esencial para la conservación del suelo en regiones desérticas, al evitar la erosión y proveer refugio a fauna local. Además, sus hojas y fibras han sido tradicionalmente utilizadas en la fabricación de textiles y cuerdas.",
                url: "https://mexico.inaturalist.org/taxa/50821-Agave-angustifolia",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F12.jpeg?alt=media&token=1e363e0f-0ff0-4423-a95d-c59e55f529e8"
            ),
            Plant(
                plantId: "13",
                name: "Altea",
                scientificName: "Malvaviscus arboreus",
                description: "La Altea es un arbusto ornamental que destaca por sus flores rojas en forma de campana, las cuales florecen durante todo el año en climas tropicales. Originaria de México, esta planta no solo embellece los paisajes, sino que también tiene usos medicinales. Sus flores y hojas son utilizadas en infusiones para aliviar la tos, fiebre y problemas digestivos. Además, es una fuente importante de alimento para colibríes y abejas, contribuyendo al equilibrio ecológico de su entorno. Su capacidad de adaptarse a diferentes condiciones la hace ideal para jardines y espacios verdes.",
                url: "https://mexico.inaturalist.org/taxa/120942-Malvaviscus-arboreus",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F13.jpg?alt=media&token=32fec88d-13d5-4956-beb1-e8b5b34e627b"
            ),
            Plant(
                plantId: "14",
                name: "Jabonera europea",
                scientificName: "Anagallis arvensis",
                description: "La Jabonera europea es una planta herbácea de origen europeo que se ha naturalizado en México y otras regiones del mundo. Crece en suelos pobres y campos abiertos, y sus pequeñas flores, que pueden ser de color rojo o azul, son un rasgo distintivo. En la tradición popular, se ha utilizado como un limpiador natural debido a las propiedades espumantes de sus hojas. También se le atribuyen usos medicinales, como el tratamiento de problemas cutáneos y heridas leves, aunque en dosis altas puede ser tóxica. Su presencia refleja la interacción entre especies nativas y naturalizadas en los ecosistemas.",
                url: "https://mexico.inaturalist.org/taxa/791928-Lysimachia-arvensis",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F14.jpg?alt=media&token=9c7ce1d2-029b-4352-ab34-3b44fdc1bedb"
            ),
            Plant(
                plantId: "15",
                name: "Té de milpa",
                scientificName: "Bidens aurea",
                description: "El Té de milpa es una planta herbácea de tallos altos y flores amarillas, típica de zonas húmedas y agrícolas de México. Se utiliza en infusiones medicinales para aliviar problemas digestivos y resfriados. Además, es una planta resistente que crece en campos y bordes de caminos, contribuyendo a la biodiversidad al atraer polinizadores como abejas y mariposas. Su carácter medicinal y su conexión con las prácticas tradicionales la convierten en una especie emblemática del campo mexicano.",
                url: "http://www.conabio.gob.mx/malezasdemexico/asteraceae/bidens-aurea/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F15.jpeg?alt=media&token=565908be-5840-4b55-9eb6-8840c1aab578"
            ),
            Plant(
                plantId: "16",
                name: "Engordacabra",
                scientificName: "Dalea bicolor",
                description: "El Engordacabra es una leguminosa de porte bajo, nativa de las regiones áridas de México. Sus pequeñas flores púrpuras y hojas compuestas la hacen fácilmente reconocible. Es una planta forrajera muy apreciada por su capacidad de alimentar al ganado, especialmente en épocas de sequía. Además, como fijadora de nitrógeno, mejora la calidad del suelo donde crece, aportando beneficios tanto ecológicos como económicos.",
                url: "http://www.conabio.gob.mx/malezasdemexico/fabaceae/dalea-bicolor/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F16.jpg?alt=media&token=98379f1e-68cc-49b4-93e5-0f2299241181"
            ),
            Plant(
                plantId: "17",
                name: "Mushel espinoso",
                scientificName: "Acacia bilimekii",
                description: "El Mushel espinoso es un árbol pequeño y resistente, característico de las regiones áridas y semiáridas de México. Su tronco presenta espinas prominentes, y sus flores amarillas en forma de esferas son muy atractivas para polinizadores. Este árbol desempeña un papel importante en la conservación del suelo y como refugio para la fauna local. Su madera es utilizada en la fabricación de herramientas y como combustible en comunidades rurales.",
                url: "https://mexico.inaturalist.org/taxa/276418-Acacia-bilimekii",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F17.jpeg?alt=media&token=e9b8fe79-4a80-4a24-8122-531eaa99aac5"
            ),
            Plant(
                plantId: "18",
                name: "Alfombrilla de campo",
                scientificName: "Glandularia bipinnatifida",
                description: "La Alfombrilla de campo es una planta herbácea rastrera que crece en campos abiertos y bordes de caminos. Sus pequeñas flores de color rosa o morado forman densas alfombras que embellecen el paisaje. Además de su valor ornamental, es apreciada por atraer mariposas y abejas, contribuyendo a la polinización en su entorno. Es una planta resistente y de bajo mantenimiento, ideal para la revegetación de áreas degradadas.",
                url: "http://www.conabio.gob.mx/malezasdemexico/verbenaceae/verbena-bipinnatifida/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F18.jpg?alt=media&token=c3d9c5c5-5918-465b-b124-25514c1e96c5"
            ),
            Plant(
                plantId: "19",
                name: "Girasol morado",
                scientificName: "Cosmos bipinnatus",
                description: "El Girasol morado, también conocido como cosmos, es una planta herbácea de flores grandes y vistosas, que varían entre tonos morados, rosas y blancos. Originaria de México, es muy popular en jardines por su belleza y facilidad de cultivo. Además, es una planta clave para la biodiversidad, ya que atrae polinizadores y aves. En algunas comunidades, se usa como ornamental en ceremonias y eventos tradicionales.",
                url: "https://mexico.inaturalist.org/taxa/68562-Cosmos-bipinnatus",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F19.jpeg?alt=media&token=c9242ae8-f0fc-4905-9185-6d61192c768b"
            ),
            Plant(
                plantId: "20",
                name: "Ahuejote",
                scientificName: "Salix bonplandiana",
                description: "El Ahuejote es un árbol alto y elegante, típico de zonas húmedas como riberas y canales en México. Sus ramas largas y flexibles se han usado tradicionalmente para la construcción de cercas vivas y techumbres. Es una especie clave en la conservación del agua, ya que protege márgenes de ríos contra la erosión. Además, su sombra y follaje favorecen la biodiversidad en su entorno, siendo refugio para aves y pequeños animales.",
                url: "http://www.conabio.gob.mx/conocimiento/info_especies/arboles/doctos/62-salic2m.pdf",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F20.jpg?alt=media&token=add8779a-601d-4e11-9b9e-651e9b68a4ce"
            ),
            Plant(
                plantId: "21",
                name: "Árnica morada",
                scientificName: "Psilactis brevilingulata",
                description: "La Árnica morada es una planta herbácea de flores pequeñas y púrpuras, que crece en suelos secos y pedregosos. Es valorada en la medicina tradicional por sus propiedades antiinflamatorias y analgésicas, utilizadas en el tratamiento de golpes y dolores musculares. Su resistencia y capacidad para florecer en condiciones adversas la convierten en una especie importante para la revegetación de terrenos degradados.",
                url: "https://mexico.inaturalist.org/taxa/156435-Psilactis-brevilingulata",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F21.jpeg?alt=media&token=f202d1fb-3a3f-496f-8d80-e4562f0b720d"
            ),
            Plant(
                plantId: "22",
                name: "Tzitziki",
                scientificName: "Cologania broussoneti",
                description: "El Tzitziki es una leguminosa rastrera de flores pequeñas y violetas, nativa de México. Crece en praderas y bosques abiertos, donde mejora la fertilidad del suelo al fijar nitrógeno. Además, es una planta forrajera apreciada para el ganado y tiene usos tradicionales en la alimentación humana. Su resistencia a climas diversos la hace valiosa tanto ecológica como económicamente.",
                url: "http://www.conabio.gob.mx/malezasdemexico/fabaceae/cologania-broussonetii/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F22.jpg?alt=media&token=344de72b-1e4c-4569-8ea9-26ef74a70979"
            ),
            Plant(
                plantId: "23",
                name: "Injerto de huizache",
                scientificName: "Psittacanthus calyculatus",
                description: "El Injerto de huizache es una planta parásita que crece sobre árboles como el huizache y el mezquite. Sus ramas robustas y flores anaranjadas o amarillas destacan en el paisaje. Aunque es vista como una amenaza para sus anfitriones, también es valorada por sus usos tradicionales en medicina, para tratar dolores y afecciones respiratorias. Su presencia refleja la complejidad de las interacciones ecológicas en los bosques secos de México.",
                url: "https://mexico.inaturalist.org/taxa/278953-Psittacanthus-calyculatus",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F23.jpg?alt=media&token=8449adb4-295a-4679-ba99-b5d7dd0c7e25"
            ),
            Plant(
                plantId: "24",
                name: "Cinco negritos",
                scientificName: "Lantana camara",
                description: "Los Cinco negritos son un arbusto ornamental de flores multicolores que van del amarillo al rojo. Originario de América tropical, es común en jardines y áreas verdes por su belleza y fácil mantenimiento. Además, sus bayas, aunque tóxicas en grandes cantidades, son alimento para aves. Es una planta resistente que prospera en suelos pobres y es utilizada en la revegetación de terrenos erosionados.",
                url: "http://www.conabio.gob.mx/malezasdemexico/verbenaceae/lantana-camara/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F24.jpeg?alt=media&token=416b5fec-b77d-4d2b-9195-d81559730ee4"
            ),
            Plant(
                plantId: "25",
                name: "Arrocillo",
                scientificName: "Conyza canadensis",
                description: "El Arrocillo es una planta herbácea de porte alto, común en campos y terrenos perturbados. Sus pequeñas flores verdosas producen semillas ligeras que se dispersan fácilmente con el viento. Es conocida en la medicina tradicional por sus propiedades antiinflamatorias y para tratar afecciones gastrointestinales. Aunque a veces considerada una maleza, su capacidad de adaptarse a diversos ambientes la convierte en una planta resiliente y útil.",
                url: "http://www.conabio.gob.mx/malezasdemexico/asteraceae/conyza-canadensis/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F25.jpeg?alt=media&token=f3489172-03ae-4da6-bcae-a99738acf34b"
            ),
            Plant(
                plantId: "26",
                name: "Tempisque",
                scientificName: "Sideroxylon capiri",
                description: "El Tempisque es un árbol de mediano a gran tamaño, típico de climas tropicales y subtropicales de América Central y México. Su tronco robusto y su copa amplia lo convierten en una especie ideal para proporcionar sombra en campos y pastizales. Produce frutos pequeños y dulces que son alimento para aves y otros animales. Su madera, resistente y durable, es valorada en la construcción y la carpintería. Además, tiene usos tradicionales en la medicina para tratar infecciones y heridas.",
                url: "https://mexico.inaturalist.org/taxa/206527-Sideroxylon-capiri",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F26.jpeg?alt=media&token=73d196cf-1596-4d81-b8ce-8c196f9bf4a2"
            ),
            Plant(
                plantId: "27",
                name: "Capulín",
                scientificName: "Prunus capuli",
                description: "El Capulín es un árbol frutal originario de México y América Central, conocido por sus frutos pequeños, redondos y dulces, de color rojo oscuro a negro. Es una especie versátil que se cultiva en huertos y crece de forma silvestre en climas templados. Sus frutos son consumidos frescos o en preparados como mermeladas y bebidas tradicionales. Además, sus hojas y corteza tienen aplicaciones en la medicina popular para tratar problemas digestivos y respiratorios.",
                url: "https://mexico.inaturalist.org/taxa/54834-Prunus-serotina",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F27.jpg?alt=media&token=ad9d2e95-0605-4726-b581-703d8a358e5b"
            ),
            Plant(
                plantId: "28",
                name: "Verdolaga cimarrona",
                scientificName: "Alternanthera caracasana",
                description: "La Verdolaga cimarrona es una planta herbácea rastrera que crece en suelos perturbados y bordes de caminos en climas cálidos. Sus hojas pequeñas y carnosas se utilizan tradicionalmente en la alimentación y como forraje para animales. En la medicina tradicional, se le atribuyen propiedades antiinflamatorias y se usa para tratar infecciones leves. Es una planta resistente que contribuye a la cobertura del suelo en terrenos degradados.",
                url: "https://mexico.inaturalist.org/taxa/75385-Alternanthera-caracasana",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F28.jpg?alt=media&token=264f4ddb-ac71-47b4-bbfd-9599e2b34614"
            ),
            Plant(
                plantId: "29",
                name: "Cabezona",
                scientificName: "Eryngium carlinae",
                description: "La Cabezona es una planta herbácea típica de zonas montañosas en México. Sus inflorescencias espinosas y sus hojas alargadas le dan una apariencia distintiva. Se utiliza en la medicina tradicional para aliviar dolores musculares y problemas digestivos. Además, es una especie ornamental valorada en jardines por su resistencia y atractivo aspecto. Es un ejemplo de la rica diversidad botánica de los ecosistemas de altura.",
                url: "https://mexico.inaturalist.org/taxa/143907-Eryngium-carlinae",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F29.jpg?alt=media&token=104a6f79-374c-4984-bce9-33212f2360e5"
            ),
            Plant(
                plantId: "30",
                name: "Encino capulincillo",
                scientificName: "Quercus castanea",
                description: "El Encino capulincillo es un árbol robusto de hojas perennes que habita en bosques templados de México. Su corteza rugosa y sus bellotas pequeñas lo distinguen de otras especies de encinos. Es una especie clave en los ecosistemas forestales, ya que sus frutos alimentan a la fauna local y su sombra favorece el crecimiento de otras plantas. Su madera es utilizada en la elaboración de carbón y productos artesanales.",
                url: "https://mexico.inaturalist.org/taxa/275462-Quercus-castanea",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F30.jpg?alt=media&token=04c28301-7bc9-41f1-b8c4-4179938b098e"
            ),
            Plant(
                plantId: "31",
                name: "Capulincillo",
                scientificName: "Celtis caudata",
                description: "El Capulincillo es un árbol pequeño a mediano, nativo de climas templados y subtropicales de México. Sus frutos redondos y dulces son consumidos tanto por la fauna como por las personas en algunas regiones. Su madera ligera se utiliza para herramientas y artesanías. Además, su capacidad de adaptarse a suelos pobres lo hace ideal para proyectos de reforestación y conservación del suelo.",
                url: "https://mexico.inaturalist.org/taxa/286472-Celtis-caudata",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F31.jpg?alt=media&token=24a6953c-0b99-4ed1-87fb-a3a5bea8aee8"
            ),
            Plant(
                plantId: "32",
                name: "Bretónica",
                scientificName: "Lepechinia caulescens",
                description: "La Bretónica es una planta arbustiva aromática que crece en climas templados y montañosos de México. Es conocida por sus flores de tonos violetas y su aroma característico. En la medicina tradicional, se utiliza en infusiones para tratar problemas respiratorios, fiebre y dolores de cabeza. Además, su resistencia a condiciones adversas la hace una planta importante para la revegetación de áreas degradadas.",
                url: "https://mexico.inaturalist.org/taxa/286956-Lepechinia-caulescens",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F32.jpg?alt=media&token=94068bf9-391a-4775-a53c-96c5a9d11d87"
            ),
            Plant(
                plantId: "33",
                name: "Chirimoya",
                scientificName: "Annona cherimola",
                description: "La Chirimoya es un árbol frutal originario de América tropical, apreciado por sus frutos grandes, dulces y de textura cremosa. Este árbol de porte mediano requiere climas cálidos y húmedos para crecer. Sus frutos se consumen frescos y son ricos en vitaminas y minerales. Además, sus hojas tienen aplicaciones en la medicina tradicional, como infusiones para aliviar el estrés y mejorar el sueño. Es una especie de gran importancia económica y cultural en las regiones donde se cultiva.",
                url: "http://biologia.fciencias.unam.mx/plantasvasculares/ArbolesArbustosFCiencias/Angiospermas/annona_cherimola.html",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F33.jpg?alt=media&token=f9dcbfcf-82c2-4db5-8622-c4683fda5241"
            ),
            Plant(
                plantId: "34",
                name: "Zumaque",
                scientificName: "Rhus chondroloma",
                description: "El Zumaque es un arbusto de regiones áridas y semiáridas de México. Sus hojas compuestas y flores pequeñas, que se agrupan en racimos, le otorgan un aspecto único. Es conocido por su resistencia a la sequía y su capacidad de proteger suelos erosionados. En la medicina tradicional, se le atribuyen propiedades astringentes y se utiliza para tratar heridas y diarreas. Además, sus frutos secos son consumidos por aves, lo que lo convierte en un elemento importante para la fauna local.",
                url: "https://mexico.inaturalist.org/taxa/273918-Rhus-chondroloma",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F34.jpg?alt=media&token=f820ae26-c480-495d-94f9-2160f39efb84"
            ),
            Plant(
                plantId: "35",
                name: "Aguja del pastor",
                scientificName: "Erodium cicutarium",
                description: "La Aguja del pastor es una planta herbácea originaria de Europa, pero ampliamente naturalizada en México y otras regiones de América. Es conocida por sus hojas lobuladas y flores pequeñas de color rosa o púrpura. Su fruto alargado y puntiagudo, que recuerda a una aguja, le da su nombre común. Crece en terrenos perturbados y se adapta fácilmente a diversas condiciones. En la medicina tradicional, se le atribuyen propiedades astringentes y se utiliza para tratar heridas y hemorragias leves.",
                url: "https://mexico.inaturalist.org/taxa/47687-Erodium-cicutarium",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F35.jpg?alt=media&token=0367c258-878b-4264-90a1-5d97b019466f"
            ),
            Plant(
                plantId: "36",
                name: "Abrojo rojo",
                scientificName: "Boerhavia coccinea",
                description: "El Abrojo rojo es una planta rastrera que prospera en suelos secos y cálidos de México. Sus pequeñas flores rosadas o rojizas destacan entre su follaje verde oscuro. Es una planta resistente, capaz de crecer en terrenos pobres, y es utilizada en la medicina popular por sus propiedades diuréticas y antiinflamatorias. Además, es una especie importante para la recuperación de suelos degradados, ayudando a prevenir la erosión.",
                url: "http://www.conabio.gob.mx/malezasdemexico/nyctaginaceae/boerhavia-coccinea/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F36.jpg?alt=media&token=21a213eb-0fdb-497f-a002-b43c83b9c25e"
            ),
            Plant(
                plantId: "37",
                name: "Ayocote",
                scientificName: "Phaseolus coccineus",
                description: "El Ayocote es una planta trepadora nativa de México, conocida por sus flores rojas brillantes y sus semillas grandes, utilizadas en la cocina tradicional. Este frijol es un ingrediente esencial en diversos platillos mexicanos y tiene gran valor nutritivo. Además de su importancia alimentaria, sus raíces ayudan a fijar nitrógeno en el suelo, mejorando su fertilidad. Es una planta clave tanto para la agricultura como para la biodiversidad en las zonas donde se cultiva.",
                url: "http://www.conabio.gob.mx/malezasdemexico/fabaceae/phaseolus-coccineus/fichas/ficha.htm",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F37.jpg?alt=media&token=db209ff5-2dd2-4bc6-b45c-78fa5d4b0f00"
            ),
            Plant(
                plantId: "38",
                name: "Guinolo",
                scientificName: "Acacia cochliacantha",
                description: "El Guinolo es un arbusto o árbol pequeño característico de las regiones áridas y semiáridas de México. Su tronco espinoso y sus flores amarillas en forma de esferas son distintivos. Es una especie resistente a la sequía que se utiliza como forraje para el ganado y para proteger suelos de la erosión. En la medicina tradicional, su corteza y hojas se emplean para tratar infecciones y problemas respiratorios. Es un elemento fundamental en los ecosistemas secos.",
                url: "https://colombia.inaturalist.org/taxa/276419-Acacia-cochliacantha",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F38.JPG?alt=media&token=294358fc-7215-41dd-9060-c0cdb1cfaa5c"
            ),
            Plant(
                plantId: "39",
                name: "Azoyate",
                scientificName: "Baccharis conferta",
                description: "El Azoyate es un arbusto de zonas montañosas de México, conocido por su follaje denso y sus flores pequeñas y blancas. Es una especie resistente que prospera en suelos pobres y contribuye a la conservación de áreas erosionadas. En la medicina popular, se le atribuyen propiedades antiinflamatorias y se utiliza para aliviar problemas respiratorios. También es importante para la fauna local, ya que sirve de refugio y alimento para insectos polinizadores.",
                url: "https://mexico.inaturalist.org/taxa/244807-Baccharis-conferta",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F39.jpg?alt=media&token=66412694-d780-422d-b4f0-ae562a58fde6"
            ),
            Plant(
                plantId: "40",
                name: "Algodoncillo",
                scientificName: "Melochia corymbosa",
                description: "El Algodoncillo es una planta herbácea o arbustiva que crece en climas cálidos de México. Sus flores pequeñas de color rosa o lila y sus semillas cubiertas de una fina pelusa blanca le dan su nombre. Es conocida en la medicina tradicional por sus propiedades expectorantes y se utiliza para tratar resfriados y afecciones respiratorias. Además, es una planta ornamental apreciada en jardines por su atractivo y facilidad de cultivo.",
                url: "https://mexico.inaturalist.org/taxa/286413-Melochia-corymbosa",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F40.jpg?alt=media&token=6d639954-1c53-4861-b3fd-3f5391275c99"
            ),
            Plant(
                plantId: "41",
                name: "Cielitos",
                scientificName: "Ageratum corymbosum",
                description: "Planta herbácea que se caracteriza por sus flores pequeñas y vistosas, usualmente de color azul, púrpura o lila. Es originaria de regiones tropicales y subtropicales de América. Es común verla en jardines debido a su atractivo ornamental. Además, se emplea en paisajismo para proteger y estabilizar suelos en zonas con alta erosión. En medicina tradicional, algunas comunidades la usan como antiinflamatorio tópico y para tratar heridas menores. También atrae insectos polinizadores, lo que la hace importante en ecosistemas rurales.",
                url: "https://mexico.inaturalist.org/taxa/158116-Ageratum-corymbosum",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F41.jpeg?alt=media&token=d9c6ba04-8920-434d-93e2-9c0ead9b1f59"
            ),
            Plant(
                plantId: "42",
                name: "Amate negro",
                scientificName: "Ficus cotinifolia",
                description: "El amate negro es un árbol majestuoso de raíces aéreas, que alcanza alturas de hasta 30 metros. Es endémico de América tropical y subtropical, creciendo cerca de ríos y barrancos. Su densa copa brinda sombra y es vital para la fauna local, sirviendo como hogar para aves y pequeños mamíferos. Tradicionalmente, se utiliza en la medicina popular para aliviar resfriados y tos. Su madera no es muy durable, pero tiene usos en la fabricación de artesanías. Este árbol tiene un significado espiritual en muchas culturas indígenas, representando fortaleza y conexión con la naturaleza.",
                url: "https://mexico.inaturalist.org/observations/250597340",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F42.jpeg?alt=media&token=57db943a-e964-46cb-a2c7-08f0f9285992"
            ),
            Plant(
                plantId: "43",
                name: "Lengua de vaca eurasiática",
                scientificName: "Rumex crispus",
                description: "Planta perenne que se distingue por sus hojas largas, onduladas y de un verde intenso. Crece en hábitats húmedos y suelos bien drenados. Es conocida por sus propiedades medicinales, especialmente como laxante y depurativo natural, debido a su contenido de ácido oxálico y taninos. Además, sus hojas jóvenes se consumen en ensaladas o cocidas como verdura en algunas culturas rurales. A pesar de ser beneficiosa, debe consumirse con moderación, ya que cantidades altas de sus compuestos pueden resultar tóxicas.",
                url: "https://mexico.inaturalist.org/observations/251675241",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F43.jpg?alt=media&token=67a69ec4-8c85-47a3-85ea-9b77c3197e8b"
            ),
            Plant(
                plantId: "44",
                name: "Algodoncillo tropical",
                scientificName: "Asclepias curassavica",
                description: "Es una planta perenne conocida por sus flores llamativas de tonos anaranjados y rojos, que son un importante recurso para las mariposas monarca, tanto en su etapa de alimentación como de reproducción. Se encuentra en campos abiertos y áreas degradadas, siendo una especie resistente. Además de su rol ecológico, tiene aplicaciones medicinales: se utiliza para tratar infecciones intestinales y como purgante. En algunos lugares, también se cultiva como planta ornamental debido a su belleza y resistencia.",
                url: "https://mexico.inaturalist.org/taxa/75602-Asclepias-curassavica",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F44.jpeg?alt=media&token=5852fddd-4e0d-4c22-97ab-0d2cc614e42a"
            ),
            Plant(
                plantId: "45",
                name: "Chayotillo",
                scientificName: "Krameria cytisoides",
                description: "Arbusto pequeño que prospera en climas áridos y suelos pobres. Produce flores púrpuras vibrantes, lo que lo convierte en un recurso atractivo para polinizadores como abejas y mariposas. La raíz del chayotillo contiene compuestos astringentes que se usan en la medicina tradicional para tratar infecciones y como enjuague bucal para aliviar el dolor dental. En algunas culturas, sus pigmentos naturales se extraen para teñir tejidos.",
                url: "https://mexico.inaturalist.org/observations/244392388",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F45.jpeg?alt=media&token=1b4b5587-eced-4fbe-8395-8e6b453a9691"
            ),
            Plant(
                plantId: "46",
                name: "Chupamiel rosa",
                scientificName: "Lamourouxia dasyantha",
                description: "Una planta hemiparásita que depende parcialmente de otras plantas para sobrevivir. Es común en bosques montañosos, donde sus flores tubulares de color rosa brillante son una fuente de néctar para aves como colibríes. Esta planta tiene importancia cultural y medicinal, ya que se utiliza en infusiones para tratar resfriados y dolores de garganta. Además, su capacidad para prosperar en suelos difíciles la hace un recurso importante en la restauración de ecosistemas degradados.",
                url: "https://mexico.inaturalist.org/observations/251713948",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F46.jpg?alt=media&token=8981640a-e1e9-47b2-b878-47bdfb7c730f"
            ),
            Plant(
                plantId: "47",
                name: "Gomphrena decumbens",
                scientificName: "Amelanchier denticulata",
                description: "Planta rastrera de tallos flexibles y flores pequeñas que se adapta bien a climas secos. Es utilizada tradicionalmente en la medicina popular para tratar problemas estomacales y como diurético suave. Aunque no es muy conocida en la horticultura, sus hojas contienen compuestos antioxidantes que podrían tener aplicaciones farmacéuticas. También desempeña un rol ecológico al proporcionar refugio a pequeños insectos.",
                url: "https://mexico.inaturalist.org/observations?taxon_id=165087",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F47.jpg?alt=media&token=e31ed41b-8bbf-4887-be34-55a1538a27a5"
            ),
            Plant(
                plantId: "48",
                name: "Tlaxistle",
                scientificName: "Amelanchier denticulata",
                description: "Este arbusto endémico de México se reconoce por sus pequeñas flores blancas y frutos redondeados comestibles, similares a las cerezas. Los frutos del tlaxistle son dulces y se utilizan para hacer mermeladas y postres locales. Es resistente a la sequía, lo que lo convierte en una opción ideal para proyectos de reforestación en áreas áridas. Además, sus raíces profundas contribuyen a estabilizar suelos, y sus hojas tienen propiedades astringentes utilizadas para tratar diarreas.",
                url: "https://mexico.inaturalist.org/taxa/165087-Malacomeles-denticulata",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F48.jpeg?alt=media&token=03b29383-488b-44c6-8e09-8481332479c9"
            ),
            Plant(
                plantId: "49",
                name: "Barba de chivo",
                scientificName: "Clematis dioica",
                description: "Trepadora vigorosa que puede alcanzar grandes alturas al aferrarse a otras plantas o estructuras. Sus flores blancas son fragantes y tienen un aspecto delicado. Es muy valorada en la jardinería ornamental por su capacidad de cubrir pérgolas y muros. En la medicina tradicional, sus hojas se aplican en forma de cataplasma para aliviar dolores musculares. También juega un papel ecológico, proporcionando alimento a diversas especies de insectos.",
                url: "https://mexico.inaturalist.org/observations/251573192",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F49.jpg?alt=media&token=ad0bc7e6-24dc-4d26-a4a3-7d35ddda9752"
            ),
            Plant(
                plantId: "50",
                name: "Suapatle",
                scientificName: "Croton dioicus",
                description: "Este arbusto aromático es un elemento destacado en la medicina tradicional mexicana. Sus hojas contienen aceites esenciales con propiedades antimicrobianas y antiinflamatorias. Se emplea para tratar infecciones hepáticas, problemas gastrointestinales y como desparasitante. Es una planta que crece bien en climas cálidos y secos, y su aroma característico lo convierte en un repelente natural de insectos.",
                url: "https://mexico.inaturalist.org/observations/242824026",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F50.jpg?alt=media&token=1d43a830-5106-4e77-ae19-ca3cd17b7b49"
            ),
            Plant(
                plantId: "51",
                name: "Chipipilá-quiui",
                scientificName: "Bauhinia dipetala",
                description: "Un arbusto o árbol pequeño con hojas bilobuladas que recuerda a las patas de un camello. Produce flores blancas que atraen a polinizadores, como abejas. Es comúnmente utilizado en cercas vivas debido a su resistencia. En la medicina popular, las hojas y la corteza se emplean en decocciones para tratar infecciones de la piel y reducir inflamaciones. Es una planta de gran valor ecológico, ya que fija nitrógeno en el suelo, mejorando su fertilidad.",
                url: "https://mexico.inaturalist.org/observations/150131366",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F51.jpeg?alt=media&token=e2624b26-132b-4215-a0a1-008e661c1bec"
            ),
            Plant(
                plantId: "52",
                name: "Psychopterys dipholiphylla",
                scientificName: "Mascagnia dipholiphylla",
                description: "Psychopterys dipholiphylla es una planta trepadora endémica de México, conocida por sus hojas bilobuladas y flores amarillas. Crece en matorrales xerófilos y bosques tropicales secos. Es importante para la restauración de ecosistemas degradados, ya que protege suelos de la erosión. Tradicionalmente, se le han atribuido propiedades medicinales para tratar dolores estomacales. También es apreciada en jardines como cobertura natural debido a su capacidad para trepar estructuras.",
                url: "https://mexico.inaturalist.org/observations/27563634",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F52.jpeg?alt=media&token=d03135b4-7761-4317-a115-0d84e8f02803"
            ),
            Plant(
                plantId: "53",
                name: "Zapote blanco",
                scientificName: "Casimiroa edulis",
                description: "El zapote blanco es un árbol frutal nativo de México y América Central, conocido por su fruto dulce y cremoso, consumido fresco o en postres. Puede alcanzar hasta 20 metros de altura y tiene hojas compuestas de color verde brillante. En la medicina tradicional, su semilla y hojas se utilizan para tratar la hipertensión y como sedante natural. Además, su madera es resistente y se emplea en carpintería. Es un árbol importante en sistemas agroforestales, ya que proporciona sombra y alimento.",
                url: "https://mexico.inaturalist.org/observations/251249370",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F53.jpeg?alt=media&token=9b7f8357-2f7d-4f72-a563-40abdb84edee"
            ),
            Plant(
                plantId: "54",
                name: "Bejuco de margarita",
                scientificName: "Echinoptery s eglandulosa",
                description: "Esta planta trepadora es típica de regiones cálidas y secas, donde se desarrolla entre matorrales y bosques tropicales secos. Sus flores amarillas en forma de margarita son atractivas para polinizadores como abejas y mariposas. Se utiliza tradicionalmente como planta ornamental en cercas vivas. Además, en algunos lugares se cree que sus raíces tienen propiedades calmantes para aliviar molestias musculares.",
                url: "https://mexico.inaturalist.org/observations/250962187",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F54.jpeg?alt=media&token=768f9745-fa5e-4f1c-b6ef-c180c583bb04"
            ),
            Plant(
                plantId: "55",
                name: "Hierba del perro",
                scientificName: "Roldana ehrenbergiana",
                description: "Una planta perenne que prospera en bosques templados y subtropicales, especialmente en pendientes rocosas. Es conocida por sus flores amarillas, que florecen en invierno, aportando color a paisajes secos. Su nombre común proviene de creencias tradicionales que relacionaban su uso medicinal con el tratamiento de mordeduras de perro. Además, tiene propiedades antimicrobianas y antiinflamatorias. Es una especie resistente que contribuye a estabilizar suelos en zonas erosionadas.",
                url: "https://mexico.inaturalist.org/taxa/160363-Cestrum-fasciculatum",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F55.jpg?alt=media&token=9da0a81e-ab8d-498c-bd3f-abd8c3c6a2c7"
            ),
            Plant(
                plantId: "56",
                name: "Hierba de San Juan",
                scientificName: "Bouvardia erecta",
                description: "Una planta herbácea nativa de México, con flores tubulares rojas que atraen colibríes. Es conocida por su uso en jardines como planta ornamental y por su papel en la polinización. En la medicina tradicional, se emplea para tratar heridas y como estimulante natural. Además, es una especie de interés para proyectos de restauración ecológica debido a su adaptabilidad a climas secos.",
                url: "https://mexico.inaturalist.org/observations/249499292",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F57.jpeg?alt=media&token=0124d2a8-e3c2-44df-b2ef-b63701a77e10"
            ),
            Plant(
                plantId: "57",
                name: "Guaje rojo",
                scientificName: "Leucaena esculenta",
                description: "Este árbol o arbusto es nativo de México y América Central, conocido por sus vainas comestibles que tienen semillas ricas en proteínas. Es utilizado en sistemas agroforestales como fertilizante natural, ya que fija nitrógeno en el suelo. Su madera se emplea en la fabricación de herramientas y cercas. En la medicina popular, se utilizan sus hojas y semillas para tratar infecciones y como antiparasitario.",
                url: "https://mexico.inaturalist.org/observations/251688025",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F57.jpeg?alt=media&token=0124d2a8-e3c2-44df-b2ef-b63701a77e10"
            ),
            Plant(
                plantId: "58",
                name: "Estrellita",
                scientificName: "Ageratina espinosarum",
                description: "Una planta arbustiva que crece en zonas montañosas y se distingue por sus flores pequeñas y blancas que forman racimos estrellados. Es comúnmente utilizada para decorar jardines debido a su resistencia y facilidad de cultivo. En la medicina tradicional, se le atribuyen propiedades antiinflamatorias y se usa en infusiones para aliviar problemas respiratorios.",
                url: "https://mexico.inaturalist.org/taxa/48178-Galinsoga-parviflora",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F58.jpeg?alt=media&token=bb800d7d-b16d-46b1-af9c-8c3a2213f740"
            ),
            Plant(
                plantId: "59",
                name: "Acacia",
                scientificName: "Acacia farnesiana",
                description: "También conocida como huizache, es un arbusto espinoso que crece en climas secos y suelos pobres. Sus pequeñas flores amarillas tienen un aroma dulce y son una fuente de néctar para abejas. Su madera es resistente y se utiliza en la construcción de herramientas. En la medicina tradicional, su corteza se emplea para tratar problemas estomacales. También se usa en perfumería debido al aroma de sus flores.",
                url: "https://mexico.inaturalist.org/taxa/47452-Acacia",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F59.jpg?alt=media&token=bc8058df-0838-41f7-aca7-124291ba6f25"
            ),
            Plant(
                plantId: "60",
                name: "Duraznillo",
                scientificName: "Harpalyce formosa",
                description: "Un arbusto de porte elegante, conocido por sus hojas brillantes y flores rosadas o púrpuras que florecen en invierno. Es endémico de México y se encuentra en bosques templados. En la medicina tradicional, se emplea como antiinflamatorio y para tratar afecciones renales. Su madera se utiliza para elaborar herramientas pequeñas y su raíz tiene aplicaciones en remedios caseros.",
                url: "https://mexico.inaturalist.org/observations?taxon_id=48502",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F60.jpeg?alt=media&token=c0c3e8d3-41b2-46de-a2cf-319380135f7c"
            ),
            Plant(
                plantId: "61",
                name: "Ramón",
                scientificName: "Cercocarpus fothergilloides",
                description: "El ramón es un árbol de tamaño mediano que crece en regiones montañosas de México. Es conocido por sus hojas pequeñas y su capacidad de prosperar en suelos pobres. En la agricultura, se utiliza para sombra y como alimento para el ganado en épocas de sequía. En la medicina tradicional, su corteza se emplea en decocciones para tratar problemas respiratorios. Además, su madera se usa para fabricar utensilios y cercas.",
                url: "https://mexico.inaturalist.org/observations/199121465",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F61.jpeg?alt=media&token=266a6898-29d0-446b-ad99-807e48e34273"
            ),
            Plant(
                plantId: "62",
                name: "Encino",
                scientificName: "Quercus frutex",
                description: "Este arbusto o árbol pequeño de la familia de las fagáceas es típico de bosques templados y secos. Tiene hojas lobuladas y produce pequeñas bellotas que sirven de alimento a la fauna local. Es importante para la estabilización de suelos y la conservación del agua en pendientes. En la medicina popular, su corteza se utiliza para tratar diarreas y heridas debido a sus propiedades astringentes. Además, tiene un valor cultural significativo, siendo símbolo de fortaleza y longevidad en muchas culturas indígenas.",
                url: "https://mexico.inaturalist.org/taxa/49013-Quercus-virginiana",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F62.jpeg?alt=media&token=6bf5dc4d-faa1-4580-adca-d2bd0414ec69"
            ),
            Plant(
                plantId: "63",
                name: "Cuajiote colorado",
                scientificName: "Bursera galeottiana",
                description: "El cuajiote colorado es un árbol caducifolio nativo de México, conocido por su característica corteza roja que se desprende en láminas delgadas. Este árbol se encuentra en bosques tropicales secos y es resistente a climas áridos. Se utiliza en la medicina tradicional para tratar problemas de la piel y heridas. Su madera es liviana, ideal para fabricar utensilios, y su resina tiene aplicaciones en ceremonias religiosas.",
                url: "https://mexico.inaturalist.org/observations/251313109",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F63.jpeg?alt=media&token=4b349d4e-248c-45e1-a909-f7bfc3dd4dbd"
            ),
            Plant(
                plantId: "64",
                name: "Tememetla",
                scientificName: "Echeveria gibbiflora",
                description: "Una suculenta perenne que forma rosetas de hojas carnosas de tonos verdes a rojizos. Es endémica de México y prospera en climas áridos. Es popular como planta ornamental en jardines xerófilos debido a su resistencia y belleza. Tradicionalmente, sus hojas se han utilizado en remedios caseros para tratar inflamaciones y quemaduras leves.",
                url: "https://mexico.inaturalist.org/observations/251737817",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F64.jpeg?alt=media&token=4703d703-6ab9-455f-937b-1c3051413f9f"
            ),
            Plant(
                plantId: "65",
                name: "Viborona",
                scientificName: "Asclepias glaucescens",
                description: "La viborona es una planta herbácea conocida por sus flores pequeñas y coloridas, que son esenciales para el ciclo de vida de las mariposas monarca. Crece en zonas montañosas y matorrales secos. Se utiliza en la medicina tradicional como antiinflamatorio y para tratar picaduras de insectos. También tiene un papel importante en la conservación ecológica por su interacción con polinizadores.",
                url: "https://mexico.inaturalist.org/observations/251370980",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F65.jpeg?alt=media&token=4c43ce9b-45fe-4b60-b102-3bba351d6680"
            ),
            Plant(
                plantId: "66",
                name: "Encino prieto",
                scientificName: "Quercus glaucoides",
                description: "Un árbol robusto que crece en altitudes elevadas, caracterizado por su corteza oscura y hojas coriáceas de tonos glaucos. Es una especie clave en los ecosistemas montañosos, proporcionando refugio y alimento a la fauna. En la medicina tradicional, su corteza se utiliza como astringente para tratar heridas y afecciones gastrointestinales. Su madera es resistente y se emplea en la construcción.",
                url: "https://mexico.inaturalist.org/observations/251247449",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F66.jpeg?alt=media&token=14cb8997-e1f3-448f-a8ed-351617c59e6f"
            ),
            Plant(
                plantId: "67",
                name: "Cenicillo Amarillo",
                scientificName: "Helianthemum glomeratum",
                description: "Una planta de bajo crecimiento con flores amarillas brillantes que florecen en primavera. Se encuentra en praderas y matorrales, tolerando suelos pobres y secos. Es valorada en la restauración ecológica debido a su capacidad para prevenir la erosión del suelo. En la medicina popular, se usa en infusiones para aliviar resfriados y fiebres.",
                url: "https://mexico.inaturalist.org/observations/250852484",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F67.png?alt=media&token=eaa2c369-230c-4abd-a167-41584ebb78bd"
            ),
            Plant(
                plantId: "68",
                name: "Flourensia glutinosa",
                scientificName: "Flourensia glutinosa",
                description: "Un arbusto aromático que crece en climas secos y se caracteriza por sus hojas pegajosas y flores amarillas. Es utilizado en la medicina tradicional para tratar dolores musculares y reumatismo. También se emplea en ceremonias indígenas como planta ritual. Su extracto tiene propiedades antimicrobianas.",
                url: "https://mexico.inaturalist.org/observations?taxon_id=157346",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F68.jpg?alt=media&token=ba008938-4383-41bc-a45a-b9aa0f54855b"
            ),
            Plant(
                plantId: "69",
                name: "Tatalencho",
                scientificName: "Gymnosperma glutinosum",
                description: "Una planta perenne utilizada en la medicina tradicional mexicana para tratar dolores de cabeza y fiebres. Crece en matorrales secos y praderas. Sus hojas y flores tienen un aroma distintivo y se usan en infusiones. También tiene aplicaciones en la restauración ecológica debido a su capacidad para crecer en suelos degradados.",
                url: "https://mexico.inaturalist.org/observations/251739505",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F69.jpeg?alt=media&token=56c06f5c-d811-4710-94e0-1ef1c149ae90"
            ),
            Plant(
                plantId: "70",
                name: "Machaonia hahniana",
                scientificName: "Machaonia hahniana",
                description: "Un arbusto endémico de México que se encuentra en bosques tropicales secos. Sus flores pequeñas y blancas son atractivas para polinizadores. Es poco estudiada, pero se cree que tiene aplicaciones potenciales en la medicina tradicional para tratar infecciones menores y dolores musculares.",
                url: "https://mexico.inaturalist.org/observations/180779102",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F70.jpeg?alt=media&token=f72ec414-ae8f-4fbd-832a-5f9a7aa6c40c"
            ),
            Plant(
                plantId: "71",
                name: "Bejuco tronador",
                scientificName: "Cardiospermum halicacabum",
                description: "Esta planta trepadora es conocida por sus frutos en forma de cápsulas infladas que parecen globos. Crece en climas tropicales y subtropicales. Se utiliza en la medicina tradicional para tratar problemas de la piel y reumatismo. También tiene propiedades antiinflamatorias y antioxidantes.",
                url: "https://mexico.inaturalist.org/observations/251500498",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F71.jpeg?alt=media&token=7685cb01-0102-4ca3-a4b8-b4aca16e5b16"
            ),
            Plant(
                plantId: "72",
                name: "Huesillo",
                scientificName: "Senna holwayana",
                description: "Un arbusto que prospera en climas cálidos y secos, con flores amarillas brillantes. Se utiliza en la medicina popular como laxante natural y para tratar infecciones intestinales. Es una planta resistente que también ayuda a prevenir la erosión del suelo.",
                url: "https://mexico.inaturalist.org/observations/234051109",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F72.jpg?alt=media&token=c0fdd48b-d257-41f0-96e8-107c70664a20"
            ),
            Plant(
                plantId: "73",
                name: "Tullidora",
                scientificName: "Karwinskia humboldtiana",
                description: "Un arbusto espinoso que produce frutos negros tóxicos para el ganado, pero que en dosis controladas se utilizan en la medicina tradicional para tratar infecciones cutáneas. Crece en climas áridos y su madera se emplea en la fabricación de herramientas y utensilios.",
                url: "https://mexico.inaturalist.org/observations/251622982",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F73.jpeg?alt=media&token=016a2554-2ac7-4469-8f66-993deb173ead"
            ),
            Plant(
                plantId: "74",
                name: "Cacahuete",
                scientificName: "Arachis hypogaea",
                description: "El cacahuete es una leguminosa cultivada en todo el mundo por sus semillas ricas en nutrientes. Es una fuente importante de proteínas y aceites vegetales. Además de su valor alimenticio, se utiliza en la medicina tradicional para tratar afecciones respiratorias y problemas digestivos. Su cultivo contribuye a la fertilidad del suelo mediante la fijación de nitrógeno.",
                url: "https://mexico.inaturalist.org/observations/246205958",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F74.jpeg?alt=media&token=2a887b7c-bcf4-4698-91a5-5094b78ec3cb"
            ),
            Plant(
                plantId: "75",
                name: "Chomonque",
                scientificName: "Gochnatia hypoleuca",
                description: "El chomonque es un arbusto perenne conocido por sus hojas plateadas y flores amarillas. Tiene aplicaciones medicinales para tratar afecciones respiratorias y problemas digestivos. También se utiliza en la restauración ecológica por su capacidad de crecer en suelos pobres.",
                url: "https://mexico.inaturalist.org/observations/243895292",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F75.jpg?alt=media&token=4fc35883-0f5e-4444-b779-372fba243319"
            ),
            Plant(
                plantId: "76",
                name: "Mazorquilla",
                scientificName: "Phytolacca icosandra",
                description: "Una planta herbácea con tallos rojizos y racimos de pequeñas flores blancas. Sus frutos, aunque tóxicos en grandes cantidades, tienen aplicaciones medicinales en dosis controladas para tratar infecciones cutáneas. Es utilizada en la elaboración de tintes naturales.",
                url: "https://mexico.inaturalist.org/observations/251392435",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F76.jpg?alt=media&token=c610deff-0664-49d8-b666-9add7a53055d"
            ),
            Plant(
                plantId: "77",
                name: "Matagallina",
                scientificName: "Capparis incana",
                description: "Un arbusto espinoso que prospera en climas secos. Sus frutos son comestibles y sus raíces se utilizan en la medicina tradicional como tónico para el sistema digestivo. También se emplea en la restauración de suelos degradados.",
                url: "https://mexico.inaturalist.org/observations/245188244",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F77.jpg?alt=media&token=7f933dfd-cd24-46ee-9032-a632ec14ae13"
            ),
            Plant(
                plantId: "78",
                name: "Trébol amargo",
                scientificName: "Melilotus indicus",
                description: "Una planta anual que crece en praderas y bordes de caminos. Es conocida por sus flores amarillas y su sabor amargo. Se utiliza en la medicina popular para tratar inflamaciones y como diurético natural. Además, es útil en la agricultura como abono verde para mejorar la calidad del suelo.",
                url: "https://mexico.inaturalist.org/observations/251706919",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F78.jpg?alt=media&token=ace26caf-7d2d-4d89-853a-f4658cf44955"
            ),
            Plant(
                plantId: "79",
                name: "Bricho pico de cuervo",
                scientificName: "Brongniartia intermedia",
                description: "Una planta herbácea con flores moradas que crece en matorrales y bosques tropicales secos. Es valiosa para la conservación del suelo y como refugio para polinizadores. En la medicina tradicional, se usa para tratar infecciones respiratorias y problemas de la piel.",
                url: "https://mexico.inaturalist.org/observations/251696208",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F79.jpg?alt=media&token=d46d3f65-0422-4bf2-9114-3c669015864d"
            ),
            Plant(
                plantId: "80",
                name: "Árnica",
                scientificName: "Grindelia inuloides",
                description: "El árnica es conocida por sus flores amarillas y propiedades medicinales. Crece en praderas y matorrales de climas templados. Se utiliza en ungüentos y pomadas para tratar golpes, inflamaciones y dolores musculares. Además, sus infusiones se emplean para aliviar resfriados y molestias respiratorias. Es una planta clave en la medicina tradicional mexicana.",
                url: "https://mexico.inaturalist.org/observations/251248436",
                dateAdded: Date(),
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/tentzo-1ee8c.firebasestorage.app/o/imagenesPlantas%2F80.jpg?alt=media&token=92b964b9-1076-4ff8-98fc-7402e1ecc835"
            )

        ]

        for plant in samplePlants {
            try await addNewPlant(plant: plant)
        }
    }

}
