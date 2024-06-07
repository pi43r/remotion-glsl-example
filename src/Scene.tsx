import { interpolate, useCurrentFrame } from 'remotion'
import { ThreeCanvas } from '@remotion/three'
import * as THREE from 'three'
import React, { useRef, useMemo } from 'react'
import { AbsoluteFill, useVideoConfig } from 'remotion'
import { z } from 'zod'
import fragmentShader from './shader/basicFragmentShader.glsl'
import vertexShader from './shader/basicVertexShader.glsl'

const container: React.CSSProperties = {
	backgroundColor: '#EFEFEF',
}

export const myCompSchema = z.object({})

type MyCompSchemaType = z.infer<typeof myCompSchema>

export const Scene: React.FC<
	{
		baseScale: number
	} & MyCompSchemaType
> = ({ baseScale }) => {
	const meshRef = useRef<THREE.Mesh>(null!)
	const { width, height } = useVideoConfig()
	const frame = useCurrentFrame()
	const { durationInFrames } = useVideoConfig()
	console.log({ fragmentShader, vertexShader })

	const constantRotation = interpolate(frame, [0, durationInFrames], [0, Math.PI * 6])

	const uniforms = useMemo(
		() => ({
			iTime: {
				type: 'f',
				value: 1.0,
			},
			iResolution: {
				type: 'v2',
				value: new THREE.Vector2(4, 3),
			},
		}),
		[]
	)

	return (
		<AbsoluteFill style={container}>
			<ThreeCanvas linear width={width} height={height}>
				<ambientLight intensity={1.5} color={0xffffff} />
				<pointLight position={[10, 10, 0]} />
				<mesh ref={meshRef} rotation={[0, constantRotation, 0]} scale={baseScale}>
					<boxGeometry args={[1, 1, 1]} />
					<shaderMaterial uniforms={uniforms} vertexShader={vertexShader} fragmentShader={fragmentShader} />
				</mesh>
			</ThreeCanvas>
		</AbsoluteFill>
	)
}
