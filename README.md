![Screenshot 2024-10-20 095121](https://github.com/user-attachments/assets/e479dda2-099e-4964-9ade-388a4d3ec339)
![Screenshot 2024-10-20 095228](https://github.com/user-attachments/assets/54ce7bc6-a1d5-4caf-90b3-0c3fbfe21a4a)
**Configuration Management**
You can manage the configuration using the following code:
```
Config = {
    emote = 'clipboard',
    FuelResource = 'qb-fuel',
    locationped = vector4(-1045.74, -2726.3, 20.17, 326.2),
    locationvehicle = vector4(-1043.06, -2723.86, 20.12, 238.63),
    ped = 'a_m_m_hasjew_01',
    starterpackladies = true,
    starterpacks = {
        umum = { -- General Starter Pack
            item = {
                ['cash'] = { amount = 5000 },
                ['sandwich'] = { amount = 10 },
                ['vodka'] = { amount = 2 },
            },
            vehicle = 'sultanrs'
        },
        ladies = {
            item = {
                ['cash'] = { amount = 15000 },
                ['sandwich'] = { amount = 15 },
                ['vodka'] = { amount = 2 },
            },
            vehicle = 'rapidgt'
        }
    }
}
```
**Add Database**
add the following columns to the players table in your database:
```
ALTER TABLE `players`
ADD COLUMN `starterpack_umum_received` TINYINT(1) NOT NULL DEFAULT 0 ,
ADD COLUMN `starterpack_ladies_received` TINYINT(1) NOT NULL DEFAULT 0 AFTER `starterpack_umum_received`;
```
You Can Reset Starterpack with this command (Only God)
```
/resetstarterpack (id)
```
