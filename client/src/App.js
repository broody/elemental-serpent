import './App.css';
import { Canvas } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';

function App() {
  return (
    <div style={{position: "fixed", top: "0", right: "0", left: "0", bottom: "0"}}>
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
