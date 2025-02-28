Config = {}

Config.Debug = false

Config.Toplama = {
    Blip = {
        Sprite = 469,
        Color = 2,
        Boyut = 75.0,
        Ad = "Ot Toplama Alanı",
        Koordinat = vector3(1065.790, 4259.520, 37.550)
    },
    Sure = 20000,
    Item = 'yosun',
    Anim = {
        Dict = 'amb@medic@standing@kneel@base',
        Clip = 'base'
    }
}

Config.Satis = {
    NPC = {
        Model = 'a_m_m_hillbilly_01',
        Koordinat = vector4(1066.81, 4252.09, 36.19, 4.22),
        Animasyon = 'WORLD_HUMAN_AA_SMOKE'
    },
    Urunler = {
        {
            item = 'yosun',
            label = 'Paketlenmiş Ot',
            fiyat = 250
        }
    }
}