import { WebpackOverrideFn } from '@remotion/bundler'

export const enableGlsl: WebpackOverrideFn = (currentConfiguration) => {
	return {
		...currentConfiguration,
		module: {
			...currentConfiguration.module,
			rules: [
				...(currentConfiguration.module?.rules ? currentConfiguration.module.rules : []),
				{
					test: /\.(glsl|vs|fs|vert|frag)$/,
					exclude: /node_modules/,
					use: ['glslify-import-loader', 'raw-loader', 'glslify-loader'],
				},
			],
		},
	}
}
