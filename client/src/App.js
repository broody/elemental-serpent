import './App.css';
import { Canvas } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';

import * as torii from '@dojoengine/torii-client';
import { useEffect } from 'react';


function App() {


  useEffect(() => {
    console.log("running");

    // let toriiClient = torii.createClient([{ model: "Game", keys: [] }], {
    //   rpcUrl: "http://localhost:5050",
    //   toriiUrl: "http://localhost:8080/rpc",
    //   worldAddress: "0x34f99c5ff5f765f682d3d9f2b303e19f155f813bd736a4165367627c53a366a"
    // });

    // const run = async () => {
    //   (await toriiClient).getModelValue("Game", []).then((value) => {
    //     console.log(value);
    //   });
    // };

    // run();
  }, []);

  return (
    <div style={{ position: "fixed", top: "0", right: "0", left: "0", bottom: "0" }}>
      <Canvas camera={{ position: [1, 2, 3] }}>
        <ambientLight intensity={0.1} />
        <gridHelper args={[100, 100, 'black', 'black']} />
        <OrbitControls />
        <mesh>
          <boxGeometry args={[2, 2, 2]} />
          <meshStandardMaterial />
        </mesh>
      </Canvas>
    </div>
  );
}

export default App;
