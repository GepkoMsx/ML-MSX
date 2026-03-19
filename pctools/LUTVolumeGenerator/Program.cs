// we hebben PCM "volume" waarden van 0-255, maar de PSG heeft slechts 16 niveaus per kanaal.
// 128 in het midden is stilte, 0 is maximale negatieve amplitude, 255 is maximale positieve amplitude.
// We willen een LUT maken die elke PCM waarde omzet naar de beste combinatie van Reg 8 en Reg 9 om die volume-intensiteit te benaderen.
// Reg 8 en Reg 9 zijn de volumeregisters voor kanaal A en B van de PSG, elk met 16 niveaus (0-15).
// Door deze twee registers te combineren, kunnen we een breder scala aan volume-intensiteiten creëren dan met één register alleen.

byte[] lut = new byte[512];
        // Genormaliseerde PSG volumeniveaus (0-15)
double[] psgLevels = { 0, 0.007, 0.010, 0.014, 0.021, 0.030, 0.043, 0.061,
                        0.086, 0.122, 0.173, 0.245, 0.347, 0.491, 0.695, 1.0 };

for (int i = 0; i < 256; i++)
{
    // Bereken de afstand tot het middelpunt (128)
    // 0 = max negatief, 128 = stil, 255 = max positief
    double intensity = i / 270.0;// Math.Abs(i - 128) / 128.0;

    byte bestReg8 = 0;
    byte bestReg9 = 0;
    byte bestReg10 = 0;
    double minDiff = 1.0;

    // Zoek de beste combinatie van Reg 8 en 9 voor deze intensiteit
    for (byte r8 = 0; r8 < 16; r8++)
    {
        for (byte r9 = 0; r9 < 16; r9++)
        {
            for (byte r10 = 0; r10 < 16; r10++)
            {
                double currentPower = (psgLevels[r8] + psgLevels[r9] + psgLevels[r10]) / 3.0;
                double diff = Math.Abs(currentPower - intensity);
                if (diff < minDiff)
                {
                    minDiff = diff;
                    bestReg8 = r8;
                    bestReg9 = r9;
                    bestReg10 = r10;
        }
            }
        }
    }

    // Index 128 forceren naar 0,0 (veiligheid)
    //if (i == 128) { bestReg8 = 0; bestReg9 = 0; bestReg10 = 0; }

    lut[i * 2] = (byte)((bestReg8 << 4) + bestReg9);
    lut[i * 2 + 1] = bestReg10;
}

File.WriteAllBytes("psg_lut.bin", lut);
Console.WriteLine("LUT met stilte op 128 gegenereerd!");
   