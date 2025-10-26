// Build the Server
await Bun.build({
	entrypoints: ['./server-src/main.ts'],
	outdir: './dist',
	target: 'node',
	minify: false,
});

// Log the Build Complete
console.log('Build complete!');
